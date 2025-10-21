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
  end
end
