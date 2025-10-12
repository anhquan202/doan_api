class Admin::UpdateRoomService
  def initialize(params)
    @params = params
  end

  def call
    room = Room.find(@params[:id])
    ActiveRecord::Base.transaction do
      room.update!(@params.except(:id, :room_supplies_attributes, :room_utilities_attributes))

      update_room_supplies(room, @params[:room_supplies_attributes]) if @params[:room_supplies_attributes]

      update_room_utilities(room, @params[:room_utilities_attributes]) if @params[:room_utilities_attributes]
    end

    Room.includes(:supplies, :utilities).find(room.id)
  end

  private

  def update_room_supplies(room, supplies_attrs)
    supplies_attrs.each do |supply_attr|
      record = RoomSupply.find_or_initialize_by(room_id: room.id, supply_id: supply_attr[:supply_id])
      record.update!(quantity: supply_attr[:quantity])
    end
  end

  def update_room_utilities(room, utilities_attrs)
    utilities_attrs.each do |utility_attr|
      record = RoomUtility.find_or_initialize_by(room_id: room.id, utility_id: utility_attr[:utility_id])
      record.update!(is_required: utility_attr[:is_required])
    end
  end
end
