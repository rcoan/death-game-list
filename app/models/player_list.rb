class PlayerList < ApplicationRecord
  belongs_to :user
  belongs_to :celebrity

  validates :position, presence: true, uniqueness: { scope: [:user_id, :year] }
  validates :celebrity_id, uniqueness: { scope: [:user_id, :year] }
  validates :year, presence: true
  validate :max_list_size

  scope :for_year, ->(year) { where(year: year) }
  scope :current_year, -> { where(year: Date.current.year) }

  private

  def max_list_size
    return unless user_id.present? && year.present?
    existing_count = persisted? ? user.player_lists.for_year(year).where.not(id: id).count : user.player_lists.for_year(year).count
    if existing_count >= 20
      errors.add(:base, "Você já tem 20 celebridades na sua lista para este ano")
    end
  end
end
