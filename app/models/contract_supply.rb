class ContractSupply < ApplicationRecord
  belongs_to :contract
  belongs_to :supply

  delegate :name, to: :supply

  enum :status, { inactive: 0, active: 1 }

  before_validation :set_default_period, on: :create

  validates :start_date, presence: true
  validate  :end_date_after_start_date

  scope :active_on, ->(date) {
    where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date)
  }

  private

  def set_default_period
    self.start_date ||= contract&.start_date || Date.current
    self.status     ||= :active
  end

  def end_date_after_start_date
    return if end_date.blank?
    errors.add(:end_date, "must be after start_date") if end_date < start_date
  end
end
