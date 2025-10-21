class Api::Admin::Utilities < Grape::API
  resources :utilities do
    desc "Get list utilities"
    get do
      utilities = ::Utility.all

      data = {
        utilities: ActiveModel::Serializer::CollectionSerializer.new(
          utilities,
          serializer: UtilitySerializer
        )
      }

      ok_response data: data
    end
  end
end
