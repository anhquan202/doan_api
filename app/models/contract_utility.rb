class ContractUtility < ApplicationRecord
  belongs_to :contract
  belongs_to :utility

  enum :status, inactive: 0, active: 1

  before_validation :set_default_period, on: :create

  private

  def set_default_period
    self.start_date ||= contract&.start_date || Date.current
    self.status     ||= :active
  end
end
