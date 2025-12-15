class Api::Admin::Dashboard < Grape::API
  before { authenticate_admin! }

  resources :dashboard do
    desc "Get summary statistics for admin dashboard"
    params do
      optional :filter, type: String, values: [ "new", "warning", "almost_expired" ], default: "new", desc: "Filter contracts: new, warning, almost_expired"
    end
    get "summary" do
      # Rooms Statistics
      total_rooms = ::Room.count
      total_available_rooms = ::Room.available_rooms.count
      total_occupied_rooms = ::Room.occupied_rooms.count
      total_cleaning_rooms = ::Room.cleaning_rooms.count
      total_repairing_rooms = ::Room.repairing_rooms.count

      room_statistics = {
        total_rooms: total_rooms,
        total_available_rooms: total_available_rooms,
        total_occupied_rooms: total_occupied_rooms,
        total_cleaning_rooms: total_cleaning_rooms,
        total_repairing_rooms: total_repairing_rooms
      }

      # Contracts Statistics
      new_contracts = ::Contract.order(created_at: :desc).limit(5)
      almost_expired_contracts = ::Contract.almost_expired
      warning_contracts = ::Contract.warning_contracts

      # determine which set to return based on filter param
      filter = params[:filter] || "new"
      filtered_contracts = case filter
      when "new"
        new_contracts
      when "almost_expired"
        almost_expired_contracts
      when "warning"
        warning_contracts
      else
        new_contracts
      end

      contracts_statistics = {
        new_contracts_count: new_contracts.count,
        almost_expired_contracts_count: almost_expired_contracts.count,
        warning_contracts_count: warning_contracts.count,
        contracts: ActiveModelSerializers::SerializableResource.new(filtered_contracts, each_serializer: ::ContractSerializer) || []
      }

      data = {
        room_statistics: room_statistics,
        contracts_statistics: contracts_statistics
      }

      ok_response data: data
    end
  end
end
