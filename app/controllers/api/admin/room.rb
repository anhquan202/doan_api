class Api::Admin::Room < Grape::API
  before { authenticate_admin! }

  helpers do
    params :create_room do
      requires :room_type, type: String, values: Room.room_types.keys
      requires :price, type: BigDecimal, desc: "Room price"
      optional :description, type: String, desc: "Room description"

      requires :room_supplies_attributes, type: Array do
        requires :supply_id, type: Integer, desc: "ID of supply"
        requires :quantity, type: Integer, default: 1
      end

      requires :room_utilities_attributes, type: Array do
        requires :utility_id, type: Integer
        requires :is_required, type: Boolean
      end
    end
  end
  resources :rooms do
    desc "Create Room"
    params do
      use :create_room
    end
    post do
      payload = declared(params, include_missing: false)

      room = Room.create!(payload)

      if room.save
        new_room = Room.includes(:supplies, :utilities).find(room.id)
        ok_response data: ::RoomSerializer.new(new_room)
      else
        error_response(message: "Validation failed", errors: room.errors.full_messages)
      end
    end
  end
end
