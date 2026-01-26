class Admin::ContractWizard::Step2TermService
  def initialize(params)
    @draft_id = params[:draft_id]
    @start_date = params[:start_date]
    @term_months = params[:term_months]
    @deposit = params[:deposit]
  end

  def call
    ActiveRecord::Base.transaction do
      draft = find_draft
      validate_step1_complete!(draft)
      validate_term!

      draft.update!(
        start_date: @start_date,
        term_months: @term_months,
        deposit: @deposit,
        current_step: 2
      )

      draft
    end
  end

  private

  def find_draft
    ContractDraft.active.find(@draft_id)
  rescue
    raise ArgumentError, "Phải hoàn thành các bước trước đó"
  end

  def validate_step1_complete!(draft)
    raise ArgumentError, "Phải hoàn thành bước 1" unless draft.step1_complete?
  end

  def validate_term!
    raise ArgumentError, "Ngày bắt đầu hợp đồng không được là ngày trong quá khứ" if @start_date.to_date < Date.current
    raise ArgumentError, "Deposit is required" if @deposit.blank?
    raise ArgumentError, "Deposit must be non-negative" if @deposit.to_f < 0
  end
end
