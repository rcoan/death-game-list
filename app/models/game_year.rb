class GameYear < ApplicationRecord
  validates :year, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(year: :desc) }

  def self.default
    active.ordered.first
  end

  def self.current
    active.ordered.first || find_by(year: Date.current.year)
  end
end
