module Admin
  module ContractWizard
    # Step 1: Create/Update customers with their vehicles
    # This step initializes the contract draft and saves customer data
    class Step1CustomersService
      def initialize(params)
        @room_id = params[:room_id]
        @draft_id = params[:draft_id]
        @customers = params[:customers] || []
      end

      def call
        ActiveRecord::Base.transaction do
          draft = find_or_create_draft
          validate_customers!

          # Store customers data in draft (as JSON for wizard flexibility)
          draft.update!(
            customers_data: build_customers_data,
            current_step: 1
          )

          draft
        end
      end

      private

      def find_or_create_draft
        if @draft_id.present?
          ContractDraft.active.find(@draft_id)
        else
          validate_room!
          ContractDraft.create!(
            room_id: @room_id,
            current_step: 1,
            status: :pending
          )
        end
      end

      def validate_room!
        room = Room.find(@room_id)
        raise ActiveRecord::RecordInvalid, "Room is not available" unless room.available?

        # Check if room already has an active draft
        existing_draft = ContractDraft.active.find_by(room_id: @room_id)
        raise ActiveRecord::RecordInvalid, "Room already has an active contract draft" if existing_draft
      end

      def validate_customers!
        raise ArgumentError, "At least one customer is required" if @customers.empty?

        # Validate at least one representative
        representatives = @customers.select { |c| c[:is_represent] }
        raise ArgumentError, "Exactly one representative is required" unless representatives.size == 1

        # Validate unique identity codes
        identity_codes = @customers.map { |c| c[:identity_code] }
        raise ArgumentError, "Duplicate identity codes found" if identity_codes.uniq.size != identity_codes.size

        # Check if identity codes already exist
        existing = Customer.where(identity_code: identity_codes).pluck(:identity_code)
        raise ArgumentError, "Identity codes already exist: #{existing.join(', ')}" if existing.any?

        # Validate vehicle plate numbers uniqueness (within this request)
        plate_numbers = @customers.filter_map { |c| c.dig(:vehicle, :plate_number) }
        raise ArgumentError, "Duplicate plate numbers found" if plate_numbers.uniq.size != plate_numbers.size

        # Check if plate numbers already exist in database (stored in vehicle_data JSON)
        if plate_numbers.any?
          existing_plates = Customer.where("JSON_EXTRACT(vehicle_data, '$.plate_number') IN (?)", plate_numbers)
                                    .pluck(Arel.sql("JSON_EXTRACT(vehicle_data, '$.plate_number')"))
          raise ArgumentError, "Plate numbers already exist: #{existing_plates.join(', ')}" if existing_plates.any?
        end
      end

      def build_customers_data
        @customers.map do |customer|
          {
            identity_code: customer[:identity_code],
            first_name: customer[:first_name],
            last_name: customer[:last_name],
            email: customer[:email],
            phone: customer[:phone],
            address: customer[:address],
            gender: customer[:gender],
            date_of_birth: customer[:date_of_birth],
            is_represent: customer[:is_represent],
            vehicle: customer[:vehicle].present? ? {
              vehicle_id: customer[:vehicle][:vehicle_id],
              plate_number: customer[:vehicle][:plate_number]
            } : nil
          }
        end
      end
    end
  end
end

