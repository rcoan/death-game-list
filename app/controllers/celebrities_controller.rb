class CelebritiesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_celebrity, only: [:show, :edit, :update, :mark_deceased]

  def index
    @celebrities = Celebrity.includes(player_lists: :user).order(:name)
  end

  def find_duplicates
    @duplicates = find_potential_duplicates
  end

  def bulk_merge
    merge_groups = params[:merge_groups] || {}
    merged_count = 0
    errors = []

    # Re-find duplicates to get the full groups
    duplicates = find_potential_duplicates

    merge_groups.each do |group_index, group_params|
      next unless group_params[:enabled] == "1"
      
      # Validate that target is selected
      if group_params[:target_id].blank?
        errors << "Grupo #{group_index.to_i + 1}: Destino não selecionado."
        next
      end

      group_index = group_index.to_i
      next unless duplicates[group_index]

      target_id = group_params[:target_id].to_i
      
      # Get selected source IDs (can be array or single value)
      source_ids = group_params[:source_ids]
      source_ids = [source_ids] unless source_ids.is_a?(Array)
      source_ids = source_ids.reject(&:blank?).map(&:to_i)
      
      if source_ids.empty?
        errors << "Grupo #{group_index + 1}: Nenhuma celebridade selecionada para mesclar."
        next
      end

      source_ids.each do |source_id|
        next if source_id == target_id

        begin
          source = Celebrity.find(source_id)
          target = Celebrity.find(target_id)

          Celebrity.transaction do
            source.player_lists.update_all(celebrity_id: target.id)
            source.destroy
          end
          merged_count += 1
        rescue StandardError => e
          errors << "Erro ao mesclar #{source&.name}: #{e.message}"
        end
      end
    end

    if errors.any?
      redirect_to find_duplicates_celebrities_path, alert: "Alguns merges falharam. #{merged_count} mesclados com sucesso. Erros: #{errors.join(', ')}"
    elsif merged_count > 0
      redirect_to celebrities_path, notice: "#{merged_count} celebridade(s) mesclada(s) com sucesso!"
    else
      redirect_to find_duplicates_celebrities_path, alert: "Nenhuma duplicata foi selecionada para mesclar."
    end
  end

  def show
  end

  def new
    @celebrity = Celebrity.new
  end

  def create
    @celebrity = Celebrity.new(celebrity_params)

    if @celebrity.save
      redirect_to celebrities_path, notice: "Celebridade criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @celebrity.update(celebrity_params)
      redirect_to celebrities_path, notice: "Celebridade atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_deceased
  end

  def update_deceased
    @celebrity = Celebrity.find(params[:id])
    
    if @celebrity.update(
      is_deceased: true,
      age_at_death: params[:celebrity][:age_at_death],
      death_date: params[:celebrity][:death_date]
    )
      redirect_to celebrities_path, notice: "Celebridade marcada como morta e pontos calculados!"
    else
      render :mark_deceased, status: :unprocessable_entity
    end
  end

  def merge
    @source_celebrity = Celebrity.find(params[:id])
    @target_celebrity = Celebrity.find(params[:target_id])

    if @source_celebrity.id == @target_celebrity.id
      redirect_to celebrities_path, alert: "Não é possível mesclar uma celebridade com ela mesma!"
      return
    end

    Celebrity.transaction do
      @source_celebrity.player_lists.update_all(celebrity_id: @target_celebrity.id)
      @source_celebrity.destroy
    end

    redirect_to celebrities_path, notice: "Celebridades mescladas com sucesso!"
  end

  private

  def set_celebrity
    @celebrity = Celebrity.find(params[:id])
  end

  def celebrity_params
    params.require(:celebrity).permit(:name, :age_at_death, :death_date, :is_deceased)
  end

  def ensure_admin
    redirect_to root_path, alert: "Acesso negado!" unless current_user&.admin?
  end

  protected

  def find_potential_duplicates
    all_celebrities = Celebrity.all.order(:name)
    duplicates = []
    processed = Set.new

    all_celebrities.each do |celebrity|
      next if processed.include?(celebrity.id)

      normalized_name = normalize_name(celebrity.name)
      similar = all_celebrities.select do |other|
        next if other.id == celebrity.id || processed.include?(other.id)
        normalized_other = normalize_name(other.name)
        names_similar?(normalized_name, normalized_other)
      end

      if similar.any?
        group = [celebrity] + similar
        duplicates << {
          group: group,
          normalized: normalized_name,
          total_lists: group.sum { |c| c.player_lists.count },
          has_deceased: group.any?(&:is_deceased?)
        }
        group.each { |c| processed.add(c.id) }
      end
    end

    duplicates.sort_by { |d| -d[:total_lists] }
  end

  def normalize_name(name)
    name.to_s.downcase
        .gsub(/[àáâãäå]/, 'a')
        .gsub(/[èéêë]/, 'e')
        .gsub(/[ìíîï]/, 'i')
        .gsub(/[òóôõö]/, 'o')
        .gsub(/[ùúûü]/, 'u')
        .gsub(/[ç]/, 'c')
        .gsub(/[ñ]/, 'n')
        # Remove aspas simples, duplas e outros caracteres de pontuação que não afetam a identidade
        .gsub(/['"`´]/, '')
        .gsub(/[.,;:!?\-_()\[\]{}]/, ' ')
        .strip
        .gsub(/\s+/, ' ')
  end

  def names_similar?(name1, name2)
    return true if name1 == name2
    
    # Check if one contains the other (for cases like "M. Schumacher" vs "Michael Schumacher")
    return true if name1.include?(name2) || name2.include?(name1)
    
    # Check Levenshtein distance (simple version)
    distance = levenshtein_distance(name1, name2)
    max_length = [name1.length, name2.length].max
    similarity = 1.0 - (distance.to_f / max_length)
    
    # Consider similar if similarity > 0.7 or if distance is small
    similarity > 0.7 || (distance <= 2 && max_length > 5)
  end

  def levenshtein_distance(str1, str2)
    m, n = str1.length, str2.length
    return n if m == 0
    return m if n == 0

    d = Array.new(m + 1) { Array.new(n + 1) }

    (0..m).each { |i| d[i][0] = i }
    (0..n).each { |j| d[0][j] = j }

    (1..m).each do |i|
      (1..n).each do |j|
        cost = str1[i - 1] == str2[j - 1] ? 0 : 1
        d[i][j] = [
          d[i - 1][j] + 1,      # deletion
          d[i][j - 1] + 1,      # insertion
          d[i - 1][j - 1] + cost # substitution
        ].min
      end
    end

    d[m][n]
  end
end

