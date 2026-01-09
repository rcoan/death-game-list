class PlayerList < ApplicationRecord
  belongs_to :user
  belongs_to :celebrity

  validates :position, presence: true, uniqueness: { scope: :user_id }
  validates :celebrity_id, uniqueness: { scope: :user_id }
  validate :max_list_size

  private

  def max_list_size
    return unless user_id.present?
    existing_count = persisted? ? user.player_lists.where.not(id: id).count : user.player_lists.count
    if existing_count >= 20
      errors.add(:base, "Você já tem 20 celebridades na sua lista")
    end
  end
end
