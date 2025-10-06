class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable, :lockable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum :status, active: 0, inactive: 1, default: :active
  enum :gender, male: 0, female: 1, other: 2

  def full_name
    "#{first_name} #{last_name}"
  end
end
