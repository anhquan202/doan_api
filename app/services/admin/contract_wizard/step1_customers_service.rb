class Admin::ContractWizard::Step1CustomersService
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
        customers_data: [],
        status: :pending
      )
    end
  end

  def validate_room!
    room = Room.find(@room_id)
    raise ArgumentError, "Phòng không tồn tại" unless room.available?
  end

  def validate_customers!
    raise ArgumentError, "Ít nhất phải có một khách hàng" if @customers.empty?

    # Validate at least one representative
    representatives = @customers.select { |c| c[:is_represent] }
    raise ArgumentError, "Phải có người đại diện" unless representatives.size == 1

    # Validate unique identity codes
    identity_codes = @customers.map { |c| c[:identity_code] }
    raise ArgumentError, "Mã định danh đã trùng lặp" if identity_codes.uniq.size != identity_codes.size

    # Prepare draft-excluded values (allow values that already belong to this draft)
    draft_identity_codes = []
    draft_plate_numbers = []
    if @draft_id.present?
      if draft = ContractDraft.active.find_by(id: @draft_id)
        draft_customers = draft.customers_data || []
        draft_identity_codes = draft_customers.map { |c| c[:identity_code] || c["identity_code"] }.compact
        draft_plate_numbers = draft_customers.filter_map { |c|
          v = c[:vehicle] || c["vehicle"]
          v && (v[:plate_number] || v["plate_number"])
        }
      end
    end

    # Check if identity codes already exist (excluding ones that belong to current draft)
    identity_codes_to_check = identity_codes - draft_identity_codes
    if identity_codes_to_check.any?
      existing = Customer.where(identity_code: identity_codes_to_check).pluck(:identity_code)
      raise ArgumentError, "Mã định danh đã tồn tại: #{existing.join(', ')}" if existing.any?
    end

    # Validate vehicle plate numbers uniqueness (within this request)
    plate_numbers = @customers.filter_map { |c| c.dig(:vehicle, :plate_number) }
    raise ArgumentError, "Biển số xe bị lặp" if plate_numbers.uniq.size != plate_numbers.size

    # Check if plate numbers already exist in database (stored in vehicle_data JSON)
    # Exclude plate numbers that belong to current draft so re-submitting the same draft won't error
    plate_numbers_to_check = plate_numbers - draft_plate_numbers
    if plate_numbers_to_check.any?
      existing_plates = Customer.where("JSON_EXTRACT(vehicle_data, '$.plate_number') IN (?)", plate_numbers_to_check)
                                .pluck(Arel.sql("JSON_EXTRACT(vehicle_data, '$.plate_number')"))
      raise ArgumentError, "Biển số xe đã tồn tại: #{existing_plates.join(', ')}" if existing_plates.any?
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
