class Year < ApplicationRecord
  validates :value, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(value: :desc) }

  def self.current
    active.ordered.first&.value || Date.current.year
  end

  def self.default
    active.where(value: 2026).first || active.ordered.first
  end
end
