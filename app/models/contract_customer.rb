class ContractCustomer < ApplicationRecord
  belongs_to :contract
  belongs_to :customer
end
