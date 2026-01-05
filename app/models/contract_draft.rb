class ContractDraft < ApplicationRecord
  belongs_to :room

  enum :status, pending: 0, completed: 1, expired: 2, cancelled: 3

  validates :room_id, presence: true
  validates :current_step, inclusion: { in: 1..3 }

  before_create :set_expiration

  scope :active, -> { where(status: :pending).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current).where(status: :pending) }

  # Step validations
  def step1_complete?
    customers_data.present? && customers_data.any?
  end

  def step2_complete?
    start_date.present? && term_months.present?
  end

  def ready_for_completion?
    step1_complete? && step2_complete? && current_step >= 3
  end

  def advance_to_step!(step)
    case step
    when 2
      raise "Step 1 not complete" unless step1_complete?
    when 3
      raise "Step 2 not complete" unless step2_complete?
    end

    update!(current_step: step)
  end

  private

  def set_expiration
    # Draft expires after 24 hours if not completed
    self.expires_at ||= 24.hours.from_now
  end
end

