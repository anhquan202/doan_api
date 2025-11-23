class Contract < ApplicationRecord
  belongs_to :room
  has_many :contract_utilities, dependent: :destroy
  has_many :contract_customers, dependent: :destroy

  has_many :utilities, through: :contract_utilities, dependent: :destroy
  has_many :customers, through: :contract_customers, dependent: :destroy

  validates :start_date, :end_date, presence: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }

  enum :status, active: 0, pending: 1, cancelled: 2

  accepts_nested_attributes_for :utilities, allow_destroy: true
  accepts_nested_attributes_for :customers, allow_destroy: true

  before_validation :calculate_end_date

  after_create :set_contract_code

  delegate :room_name, to: :room

  def start_date_formatted
    start_date&.strftime("%Y-%m-%d")
  end

  def end_date_formatted
    end_date&.strftime("%Y-%m-%d")
  end

  def representative_name
    contract_customers.find_by(is_represent: true).full_name
  end

  def customers_count
    contract_customers.count
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
