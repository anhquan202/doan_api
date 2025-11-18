class ContractUtility < ApplicationRecord
  belongs_to :contract
  belongs_to :utility

  enum :status, inactive: 0, active: 1
end
