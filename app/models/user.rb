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
      conditions[:username] = conditions[:username].downcase.strip
    end
    where(conditions).first
  end

  def total_points(year = Date.current.year)
    player_lists.for_year(year)
                .joins(:celebrity)
                .where(celebrities: { is_deceased: true })
                .sum("celebrities.points")
  end
end
