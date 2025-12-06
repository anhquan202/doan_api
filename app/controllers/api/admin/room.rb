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
      optional :status, type: Array[Integer], desc: "Array of statuses"
      optional :room_type, type: Array[Integer], desc: "Array of room types"
      optional :q, type: String
      optional :price_min, type: Integer
      optional :price_max, type: Integer
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 10
    end
    get do
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      search_params = {}
      search_params[:room_name_cont] = params[:q] if params[:q].present?
      search_params[:status_in]      = params[:status] if params[:status].present?
      search_params[:room_type_in]   = params[:room_type] if params[:room_type].present?
      search_params[:price_gteq] = params[:price_min] if params[:price_min].present?
      search_params[:price_lteq] = params[:price_max] if params[:price_max].present?

      base = Room.includes(:supplies, :utilities)

      rooms = base.ransack(search_params).result
      rooms = rooms.paginate(page: page, per_page: per_page)

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
        room: ::RoomDetailSerializer.new(room)
      }

      ok_response data: data
    end

    desc "Get available Rooms"
    params do
      optional :page, type: Integer, default: 1, desc: "Page number"
      optional :per_page, type: Integer, default: 10, desc: "Items per page"
    end
    get "available" do
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      rooms = Room.available.includes(:supplies, :utilities).paginate(page: page, per_page: per_page)

      data = {
        rooms: ActiveModel::SerializableResource.new(
          rooms,
          each_serializer: ::RoomSerializer
        ),
        meta: paginate_meta(rooms)
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

    desc "Delete Room by ID"
    params do
      requires :id, type: Integer
    end
    delete ":id" do
      room = Room.find params[:id]

      room.delete

      success_response
    end

    desc "Get list of room statuses"
    get "status" do
      data = Room.statuses.map do |key, value|
        {
          key: key,
          label: I18n.t("activerecord.attributes.room.statuses.#{key}"),
          value: value
        }
      end

      ok_response data: data
    end
  end
end
