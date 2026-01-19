class Admin::ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def new
  end

  def create
    year = params[:year].to_i
    
    # Handle file upload or use default file
    if params[:json_file].present? && params[:json_file].respond_to?(:read)
      json_content = params[:json_file].read
      json_file_path = nil
    else
      json_file_path = Rails.root.join('db', 'lists_2026_validation.json')
      unless File.exist?(json_file_path)
        redirect_to new_admin_import_path, alert: "Arquivo JSON não encontrado!"
        return
      end
      json_content = File.read(json_file_path)
    end

    begin
      json_data = JSON.parse(json_content)
      
      # Use year from JSON if not provided, or use provided year
      year = json_data['year'] if year.zero?
      
      if year.zero?
        redirect_to new_admin_import_path, alert: "Ano não especificado!"
        return
      end

      result = import_lists(json_data, year)
      
      if result[:success]
        redirect_to admin_imports_path, notice: result[:message]
      else
        redirect_to new_admin_import_path, alert: result[:message]
      end
    rescue JSON::ParserError => e
      redirect_to new_admin_import_path, alert: "Erro ao processar JSON: #{e.message}"
    rescue StandardError => e
      redirect_to new_admin_import_path, alert: "Erro ao importar: #{e.message}"
    end
  end

  def index
    @imports = [] # Could track import history in the future
  end

  private

  def import_lists(json_data, year)
    created_users = 0
    created_celebrities = 0
    created_lists = 0
    errors = []

    # Ensure GameYear exists
    game_year = GameYear.find_or_create_by!(year: year) do |gy|
      gy.start_date = Date.new(year, 1, 15)
      gy.is_active = true
    end

    lists = json_data['lists'] || []
    
    lists.each do |list_data|
      username = list_data['username']
      owner_name = list_data['owner']
      celebrities = list_data['celebrities'] || []

      # Create or find user
      user = User.find_or_initialize_by(username: username)
      if user.new_record?
        user.password = SecureRandom.hex(16)
        user.password_confirmation = user.password
        user.email = "#{username}@deaths-game.local" if user.email.blank?
        if user.save
          created_users += 1
        else
          errors << "Erro ao criar usuário #{username}: #{user.errors.full_messages.join(', ')}"
          next
        end
      end

      # Delete existing lists for this user/year
      PlayerList.where(user: user, year: year).destroy_all

      # Process each celebrity
      celebrities.each_with_index do |celebrity_name, index|
        position = index + 1
        
        # Find or create celebrity (case-insensitive)
        celebrity = Celebrity.where('LOWER(name) = ?', celebrity_name.to_s.downcase.strip).first
        if celebrity.nil?
          celebrity = Celebrity.create!(name: celebrity_name.to_s.strip)
          created_celebrities += 1
        end

        # Create player list entry
        player_list = PlayerList.new(
          user: user,
          celebrity: celebrity,
          year: year,
          position: position
        )

        if player_list.save
          created_lists += 1
        else
          errors << "Erro ao criar lista para #{username} - #{celebrity_name}: #{player_list.errors.full_messages.join(', ')}"
        end
      end
    end

    message = "Importação concluída! Usuários criados: #{created_users}, Celebridades criadas: #{created_celebrities}, Listas criadas: #{created_lists}"
    message += " | Erros: #{errors.count}" if errors.any?

    {
      success: errors.empty? || created_lists > 0,
      message: message,
      errors: errors
    }
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado!" unless current_user&.admin?
  end
end

