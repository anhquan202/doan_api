class Customer < ApplicationRecord
  has_one :contract_customer, dependent: :destroy
  has_one :contract, through: :contract_customer

  enum :status, active: 0, warning: 1, banned: 2
  enum :gender, male: 0, female: 1

  def full_name
    "#{first_name} #{last_name}"
  end
end
