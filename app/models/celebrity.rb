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
end
