class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:username],
         reset_password_keys: [:username],
         case_insensitive_keys: [:username],
         strip_whitespace_keys: [:username]

  has_many :player_lists, dependent: :destroy
  has_many :celebrities, through: :player_lists

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # Override Devise's email requirement since we use username for authentication
  def email_required?
    false
  end

  def self.find_for_authentication(conditions)
    conditions = conditions.dup
    if conditions.key?(:username)
      username = conditions.delete(:username).to_s.downcase.strip
      return where("LOWER(username) = ?", username).first
    end
    where(conditions).first
  end

  def total_points(year = Date.current.year)
    game_year = GameYear.find_by(year: year)
    return 0 unless game_year
    
    player_lists.for_year(year)
                .joins(:celebrity)
                .where(celebrities: { is_deceased: true })
                .where("celebrities.death_date >= ?", game_year.start_date)
                .where("celebrities.death_date < ?", Date.new(year + 1, 1, 1))
                .sum("celebrities.points")
  end

  # Retorna o número de vitórias (anos em que foi campeão)
  # Considera apenas anos que já terminaram
  def championship_wins
    current_year = Date.current.year
    GameYear.active.ordered.pluck(:year).select { |year| year < current_year }.count do |year|
      self == User.champion_of_year(year)
    end
  end

  # Retorna o nome do usuário com emojis de vitórias
  def display_name_with_trophies
    wins = championship_wins
    return username if wins == 0
    "#{username} #{'☠️' * wins}"
  end

  # Retorna o campeão de um ano específico
  # Retorna nil se o ano ainda não terminou (ano >= ano atual)
  def self.champion_of_year(year)
    # Não retorna campeão para anos que ainda não terminaram
    return nil if year >= Date.current.year
    
    game_year = GameYear.find_by(year: year)
    return nil unless game_year
    
    user_ids_with_lists = PlayerList.for_year(year).distinct.pluck(:user_id)
    return nil if user_ids_with_lists.empty?
    
    users_with_points = User.where(id: user_ids_with_lists).map do |user|
      { user: user, points: user.total_points(year) }
    end
    
    return nil if users_with_points.empty?
    
    max_points = users_with_points.map { |u| u[:points] }.max
    champions = users_with_points.select { |u| u[:points] == max_points }
    
    # Em caso de empate, retorna o primeiro alfabeticamente
    champions.min_by { |u| u[:user].username.downcase }[:user]
  end

  # Retorna ranking de todos os campeões ordenado por vitórias e depois alfabeticamente
  # Considera apenas anos que já terminaram (ano < ano atual)
  def self.champions_ranking
    current_year = Date.current.year
    # Filtrar apenas anos que já terminaram
    finished_years = GameYear.active.ordered.pluck(:year).select { |year| year < current_year }
    champions_by_year = finished_years.map { |year| [year, champion_of_year(year)] }.to_h
    
    # Contar vitórias por usuário
    wins_by_user = Hash.new(0)
    champions_by_year.each_value do |champion|
      wins_by_user[champion] += 1 if champion
    end
    
    # Ordenar: mais vitórias primeiro, depois alfabeticamente
    wins_by_user.to_a.sort_by { |user, wins| [-wins, user.username.downcase] }
  end
end
