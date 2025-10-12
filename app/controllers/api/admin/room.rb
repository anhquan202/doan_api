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

    params :update_room do
      optional :room_type, type: String, values: Room.room_types.keys
      optional :price, type: BigDecimal, desc: "Room price"
      optional :status, type: String, values: Room.statuses.keys
      optional :description, type: String, desc: "Room description"

      optional :room_supplies_attributes, type: Array do
        optional :supply_id, type: Integer, desc: "ID of supply"
        optional :quantity, type: Integer, default: 1
      end

      optional :room_utilities_attributes, type: Array do
        optional :utility_id, type: Integer
        optional :is_required, type: Boolean
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

    desc "List Rooms"
    params do
      optional :page, type: Integer, default: 1, desc: "Page number"
      optional :per_page, type: Integer, default: 10, desc: "Items per page"
    end
    get do
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      rooms = Room.includes(:supplies, :utilities).paginate(page: page, per_page: per_page)

      data = {
        rooms: ActiveModel::SerializableResource.new(
          rooms,
          each_serializer: ::RoomSerializer
        ),
        meta: paginate_meta(rooms)
      }

      ok_response data: data
    end

    desc "Get Room by ID"
    params do
      requires :id, type: Integer, desc: "Room ID"
    end
    get ":id" do
      room = Room.includes(:supplies, :utilities).find(params[:id])

      data = {
        room: ::RoomSerializer.new(room)
      }

      ok_response data: data
    end

    desc "Update Room by ID"
    params do
      requires :id, type: Integer, desc: "Room ID"
      use :update_room
    end
    patch ":id" do
      payload = declared(params, include_missing: false)

      Admin::UpdateRoomService.new(payload).call

      success_response
    end
  end
end
