class GameYear < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  validates :start_date, presence: true

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(year: :desc) }

  before_validation :set_default_start_date, on: :create

  def self.default
    active.ordered.first
  end

  def self.current
    active.ordered.first || find_by(year: Date.current.year)
  end

  def death_counted_for_year?(death_date)
    return false unless death_date.present?
    return false if death_date.year != year
    return false if death_date < start_date
    true
  end

  private

  def set_default_start_date
    self.start_date ||= Date.new(year, 1, 15) if year.present?
  end
end

