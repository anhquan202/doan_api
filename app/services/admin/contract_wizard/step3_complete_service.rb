module Admin
  module ContractWizard
    # Step 3: Complete the contract - create all real records
    class Step3CompleteService
      def initialize(params)
        @draft_id = params[:draft_id]
      end

      def call
        ActiveRecord::Base.transaction do
          draft = find_and_validate_draft

          # Create contract
          contract = create_contract(draft)

          # Create customers, vehicles, and contract_customers
          create_customers_and_vehicles(draft, contract)

          # Update room status
          update_room_status(draft)

          # Mark draft as completed
          draft.update!(status: :completed, current_step: 3)

          contract
        end
      end

      private

      def find_and_validate_draft
        draft = ContractDraft.active.find(@draft_id)

        raise ArgumentError, "Step 1 (customers) not completed" unless draft.step1_complete?
        raise ArgumentError, "Step 2 (term) not completed" unless draft.step2_complete?

        draft
      end

      def create_contract(draft)
        Contract.create!(
          room_id: draft.room_id,
          start_date: draft.start_date,
          term_months: draft.term_months,
          deposit: draft.deposit,
          status: :active
        )
      end

      def create_customers_and_vehicles(draft, contract)
        draft.customers_data.each do |customer_data|
          customer_data = customer_data.with_indifferent_access

          # Build vehicle_data JSON if present
          vehicle_json = nil
          if customer_data[:vehicle].present?
            vehicle_info = customer_data[:vehicle].with_indifferent_access
            vehicle = Vehicle.find_by(id: vehicle_info[:vehicle_id])
            vehicle_json = {
              vehicle_id: vehicle_info[:vehicle_id],
              vehicle_name: vehicle&.name,
              plate_number: vehicle_info[:plate_number]
            }
          end

          # Create customer with vehicle_data
          customer = Customer.create!(
            identity_code: customer_data[:identity_code],
            first_name: customer_data[:first_name],
            last_name: customer_data[:last_name],
            email: customer_data[:email],
            phone: customer_data[:phone],
            address: customer_data[:address],
            gender: customer_data[:gender],
            date_of_birth: customer_data[:date_of_birth],
            status: :active,
            vehicle_data: vehicle_json
          )

          # Create contract_customer relationship
          ContractCustomer.create!(
            contract_id: contract.id,
            customer_id: customer.id,
            is_represent: customer_data[:is_represent],
            move_in_date: draft.start_date
          )
        end
      end

      def update_room_status(draft)
        room = Room.find(draft.room_id)
        room.update!(status: :occupied)
      end
    end
  end
end

