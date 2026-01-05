module Admin
  module ContractWizard
    # Step 2: Set rental term (start_date, term_months)
    class Step2TermService
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
      end

      def validate_step1_complete!(draft)
        raise ArgumentError, "Step 1 (customers) must be completed first" unless draft.step1_complete?
      end

      def validate_term!
        raise ArgumentError, "Start date is required" if @start_date.blank?
        raise ArgumentError, "Term months is required" if @term_months.blank?
        raise ArgumentError, "Term months must be positive" if @term_months.to_i <= 0
        raise ArgumentError, "Start date cannot be in the past" if @start_date.to_date < Date.current
        raise ArgumentError, "Deposit is required" if @deposit.blank?
        raise ArgumentError, "Deposit must be non-negative" if @deposit.to_f < 0
      end
    end
  end
end

