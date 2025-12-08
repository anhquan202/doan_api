class MeterReading < ApplicationRecord
  belongs_to :contract

  enum :reading_type, { electricity: 0, water: 1 }

  validates :contract_id, :reading_type, :start_num, :end_num, :fee_at_reading, :total_fee, presence: true
  validates :start_num, :end_num, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :calculate_total_fee

  def calculate_total_fee
    usage = end_num - start_num
    self.total_fee = usage * fee_at_reading
  end
end
