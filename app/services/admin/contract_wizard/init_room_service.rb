class Admin::ContractWizard::InitRoomService
  def initialize(params)
    @room_id = params[:room_id]
    @supplies = params[:supplies] || []
    @utilities = params[:utilities] || []
  end

  def call
    ActiveRecord::Base.transaction do
      draft = create_draft
      populate_room_data(draft)
      draft
    end
  end

  private

  def create_draft
    validate_room!

    ContractDraft.create!(
      room_id: @room_id,
      current_step: 0,
      customers_data: [],
      supplies_data: build_supplies_data,
      utilities_data: build_utilities_data,
      status: :pending
    )
  end

  def validate_room!
    room = Room.find(@room_id)
    raise ArgumentError, "Phòng không tồn tại" unless room
    raise ArgumentError, "Phòng không có sẵn để cho thuê" unless room.available?
  end

  def build_supplies_data
    return {} if @supplies.blank?

    supplies_hash = {}
    @supplies.each do |supply|
      supply = supply.with_indifferent_access
      supply_obj = Supply.find_by(id: supply[:supply_id])

      supplies_hash[supply[:supply_id].to_s] = {
        supply_id: supply[:supply_id],
        supply_name: supply_obj&.name,
        unit: supply_obj&.unit,
        quantity: supply[:quantity] || 1
      }
    end

    supplies_hash
  end

  def build_utilities_data
    return {} if @utilities.blank?

    utilities_hash = {}
    @utilities.each do |utility|
      utility = utility.with_indifferent_access
      utility_obj = Utility.find_by(id: utility[:utility_id])

      utilities_hash[utility[:utility_id].to_s] = {
        utility_id: utility[:utility_id],
        utility_type: utility_obj&.utility_type,
        fee: utility_obj&.fee
      }
    end

    utilities_hash
  end

  def populate_room_data(draft)
    # Additional room data if needed (can be extended later)
    # For now, data is already populated via build_supplies_data and build_utilities_data
  end
end
