class MonthlyInvoice < ApplicationRecord
  belongs_to :contract

  enum :status, pending: 0, paid: 1, overdue: 2, cancelled: 3

  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, presence: true
  validates :contract_id, uniqueness: { scope: [:month, :year], message: "đã có hóa đơn cho tháng này" }

  before_save :calculate_total

  scope :for_period, ->(month, year) { where(month: month, year: year) }
  scope :unpaid, -> { where(status: [:pending, :overdue]) }
  scope :this_month, -> { where(month: Date.current.month, year: Date.current.year) }

  delegate :room_name, :contract_code, to: :contract

  def period_text
    "Tháng #{month}/#{year}"
  end

  def electric_reading
    contract.electric_readings.find_by(month: month, year: year)
  end

  def water_reading
    contract.water_readings.find_by(month: month, year: year)
  end

  def mark_as_paid!(payment_method: nil, note: nil)
    update!(
      status: :paid,
      paid_at: Time.current,
      payment_method: payment_method,
      note: note
    )
  end

  def recalculate_from_readings!
    electric = electric_reading
    water = water_reading

    update!(
      electric_fee: electric&.total_fee || 0,
      water_fee: water&.total_fee || 0
    )
  end

  def status_text
    I18n.t("enums.monthly_invoice.status.#{status}")
  end

  def self.ransackable_attributes(auth_object = nil)
    ["month", "year", "status", "total_amount", "contract_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["contract"]
  end

  private

  def calculate_total
    self.total_amount = (room_fee || 0) + (electric_fee || 0) + (water_fee || 0) + (service_fee || 0) + (adjustment || 0)
  end
end

