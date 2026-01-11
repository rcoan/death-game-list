class Celebrity < ApplicationRecord
  has_many :player_lists, dependent: :destroy
  has_many :users, through: :player_lists

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :calculate_points, if: :is_deceased?

  def calculate_points
    return unless age_at_death.present?
    self.points = 100 - age_at_death
  end

  def self.search(query)
    where("name ILIKE ?", "%#{query}%")
  end

  # Retorna os pontos válidos para um ano específico
  # Se a morte não contar para aquele ano, retorna 0
  def points_for_year(year)
    return nil unless is_deceased?
    return 0 unless death_date.present?
    
    game_year = GameYear.find_by(year: year)
    return 0 unless game_year
    
    # Verifica se a morte conta para este ano
    if game_year.death_counted_for_year?(death_date)
      points || 0
    else
      0
    end
  end

  # Retorna se a morte conta pontos para um ano específico
  def death_counts_for_year?(year)
    return false unless is_deceased?
    return false unless death_date.present?
    
    game_year = GameYear.find_by(year: year)
    return false unless game_year
    
    game_year.death_counted_for_year?(death_date)
  end
end
