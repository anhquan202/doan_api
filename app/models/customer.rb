class Customer < ApplicationRecord
  has_one :contract_customer, dependent: :destroy
  has_one :contract, through: :contract_customer
  delegate :room_name, to: :contract, allow_nil: true

  enum :status, active: 0, warning: 1, banned: 2
  enum :gender, male: 0, female: 1

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, :address, presence: true
  validates :identity_code, presence: true, uniqueness: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
