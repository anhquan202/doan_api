class Api::Admin::Vehicles < Grape::API
  before { authenticate_admin! }

  resources :vehicles do
    desc "Get list vehicles"
    get do
      vehicles = ::Vehicle.all

      data = {
        vehicles: ActiveModel::Serializer::CollectionSerializer.new(
          vehicles,
          serializer: VehicleSerializer
        )
      }

      ok_response data: data
    end

    desc "Update vehicle is_active"
    params do
      requires :id, type: Integer, desc: "Vehicle ID"
    end
    post ":id/active" do
      vehicle = Vehicle.find params[:id]
      vehicle.toggle_active!
      success_response
    end
  end
end
