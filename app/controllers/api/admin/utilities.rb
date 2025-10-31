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

    desc "Edit fee`s supply"
    params do
      requires :id, type: Integer
      optional :fee, type: BigDecimal
    end
    patch ":id" do
      utitlity = Utility.find params[:id]

      utitlity.update! fee: params[:fee]

      success_response
    end
  end
end
