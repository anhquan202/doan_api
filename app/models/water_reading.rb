class WaterReading < ApplicationRecord
  belongs_to :contract

  before_validation :calculate_total_fee

  validates :start_num, :end_num, :fee_at_reading, presence: true
  validates :start_num, :end_num, numericality: { greater_than_or_equal_to: 0 }

  def calculate_total_fee
    return unless start_num && end_num && fee_at_reading
    usage = end_num - start_num
    self.total_fee = usage * fee_at_reading
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "start_num", "end_num", "month", "year" ]
  end
end
