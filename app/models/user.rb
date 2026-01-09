class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :player_lists, dependent: :destroy
  has_many :celebrities, through: :player_lists

  def total_points
    player_lists.joins(:celebrity)
                .where(celebrities: { is_deceased: true })
                .sum("celebrities.points")
  end
end
