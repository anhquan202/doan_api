module Api
  module Admin
    class ContractWizard < Grape::API
      namespace :contract_wizard do
        # ============================================
        # Step 1: Create customers with vehicles
        # ============================================
        desc "Step 1: Initialize draft and add customers with vehicles"
        params do
          requires :room_id, type: Integer, desc: "Room ID for the contract"
          optional :draft_id, type: Integer, desc: "Existing draft ID (for updating)"
          requires :customers, type: Array do
            requires :identity_code, type: String, desc: "Customer identity code"
            requires :first_name, type: String, desc: "First name"
            requires :last_name, type: String, desc: "Last name"
            requires :email, type: String, desc: "Email"
            requires :phone, type: String, desc: "Phone number"
            requires :address, type: String, desc: "Address"
            requires :gender, type: Integer, values: [0, 1], desc: "Gender: 0=male, 1=female"
            requires :date_of_birth, type: Date, desc: "Date of birth"
            requires :is_represent, type: Boolean, desc: "Is representative"
            optional :vehicle, type: Hash do
              requires :vehicle_id, type: Integer, desc: "Vehicle type ID"
              requires :plate_number, type: String, desc: "Vehicle plate number"
            end
          end
        end
        post "step1" do
          draft = ::Admin::ContractWizard::Step1CustomersService.new(params).call

          ok_response(
            data: {
              draft_id: draft.id,
              current_step: draft.current_step,
              room_id: draft.room_id,
              customers_count: draft.customers_data.size,
              expires_at: draft.expires_at
            },
            message: "Step 1 completed: Customers saved"
          )
        end

        # ============================================
        # Step 2: Set rental term
        # ============================================
        desc "Step 2: Set rental term (start date, term months, deposit)"
        params do
          requires :draft_id, type: Integer, desc: "Draft ID from step 1"
          requires :start_date, type: Date, desc: "Contract start date"
          requires :term_months, type: Integer, desc: "Contract term in months"
          requires :deposit, type: Float, desc: "Deposit amount"
        end
        post "step2" do
          draft = ::Admin::ContractWizard::Step2TermService.new(params).call

          end_date = draft.start_date.advance(months: draft.term_months)

          ok_response(
            data: {
              draft_id: draft.id,
              current_step: draft.current_step,
              start_date: draft.start_date,
              end_date: end_date,
              term_months: draft.term_months,
              deposit: draft.deposit
            },
            message: "Step 2 completed: Term saved"
          )
        end

        # ============================================
        # Step 3: Complete contract creation
        # ============================================
        desc "Step 3: Finalize and create the contract"
        params do
          requires :draft_id, type: Integer, desc: "Draft ID"
        end
        post "step3" do
          contract = ::Admin::ContractWizard::Step3CompleteService.new(params).call

          ok_response(
            data: {
              contract_id: contract.id,
              contract_code: contract.contract_code,
              status: contract.status
            },
            message: "Contract created successfully"
          )
        end

        # ============================================
        # Get current draft status
        # ============================================
        desc "Get current draft status and data"
        params do
          requires :id, type: Integer, desc: "Draft ID"
        end
        get ":id" do
          draft = ::ContractDraft.active.find(params[:id])

          ok_response(
            data: {
              draft_id: draft.id,
              room_id: draft.room_id,
              current_step: draft.current_step,
              customers_data: draft.customers_data,
              start_date: draft.start_date,
              term_months: draft.term_months,
              deposit: draft.deposit,
              expires_at: draft.expires_at,
              step1_complete: draft.step1_complete?,
              step2_complete: draft.step2_complete?
            }
          )
        end

        # ============================================
        # Cancel draft
        # ============================================
        desc "Cancel the draft and release the room"
        params do
          requires :draft_id, type: Integer, desc: "Draft ID to cancel"
        end
        delete "cancel" do
          ::Admin::ContractWizard::CancelDraftService.new(params).call

          success_response message: "Draft cancelled"
        end
      end
    end
  end
end

