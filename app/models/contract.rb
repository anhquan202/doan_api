class Contract < ApplicationRecord
  belongs_to :room
  has_many :contract_utilities, dependent: :destroy
  has_many :contract_customers, dependent: :destroy
  has_many :meter_readings, dependent: :destroy

  has_many :utilities, through: :contract_utilities, dependent: :destroy
  has_many :customers, through: :contract_customers, dependent: :destroy

  validates :start_date, :end_date, presence: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }

  enum :status, active: 0, warning: 1, overdue: 2, terminated: 3, cancelled: 4

  accepts_nested_attributes_for :contract_utilities, allow_destroy: true
  accepts_nested_attributes_for :contract_customers, allow_destroy: true

  has_many :electric_readings, dependent: :destroy
  has_many :water_readings, dependent: :destroy
  has_many :monthly_invoices, dependent: :destroy

  before_validation :calculate_end_date

  after_create :set_contract_code

  delegate :room_name, to: :room

  scope :almost_expired, ->(days = 30, limit = 5) {
    where(status: :active).where(end_date: Date.today..days.days.from_now.to_date).limit(limit)
  }

  scope :warning_contracts, ->(limit = 5) {
    where(status: :warning).limit(limit)
  }

  def start_date_formatted
    start_date&.strftime("%Y-%m-%d")
  end

  def end_date_formatted
    end_date&.strftime("%Y-%m-%d")
  end

  def representative_name
    contract_customers.find_by(is_represent: true)&.full_name
  end

  def customers_count
    contract_customers.count
  end

  def fee_services
    utilities&.where.not(utility_type: [ :electricity, :water ])&.sum(:fee).to_i
  end

  def status_text
    I18n.t("activerecord.attributes.contract.statuses.#{status}")
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "contract_code", "deposit", "end_date", "id", "room_id", "start_date", "status", "term_months" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "electric_readings", "water_readings" ]
  end

  private
  def calculate_end_date
    return if start_date.blank? || term_months.blank?

    self.end_date = start_date.advance(months: term_months).end_of_day
  end

  def set_contract_code
    date_prefix = Time.zone.today.strftime("%Y%m%d")
    padded_id = id.to_s.rjust(4, "0")

    update_column(:contract_code, "#{date_prefix}#{padded_id}")
  end
end
