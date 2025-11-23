class ContractCustomer < ApplicationRecord
  belongs_to :contract
  belongs_to :customer

  delegate :full_name, to: :customer
end
