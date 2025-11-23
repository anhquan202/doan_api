class Customer < ApplicationRecord
  has_one :contract_customer, dependent: :destroy
  has_one :contract, through: :contract_customer

  def full_name
    "#{first_name} #{last_name}"
  end
end
