class Api::Admin::Supplies < Grape::API
  resources :supplies do
    desc "Get list supplies"
    get do
      supplies = ::Supply.all

      data = {
        supplies: ActiveModel::Serializer::CollectionSerializer.new(
          supplies,
          serializer: SupplySerializer
        )
      }

      ok_response data: data
    end

    desc "Create Supply"
    params do
      requires :name, type: String, desc: "Supply name"
      requires :unit, type: String, values: Supply.units.keys, desc: "Unit of supply"
    end
    post do
      payload = declared(params, include_missing: false)

      supply = Supply.new(payload)

      supply.save

      success_response
    end

    desc "Update Supply"
    params do
      requires :id, type: Integer, desc: "Supply ID"
      optional :name, type: String, desc: "Supply name"
      optional :unit, type: String, values: Supply.units.keys, desc: "Unit of supply"
    end
    patch ":id" do
      supply = Supply.find(params[:id])
      payload = declared(params, include_missing: false).except(:id)

      supply.update(payload)

      success_response
    end
  end
end
