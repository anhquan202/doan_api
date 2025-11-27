module Api
  module Admin
    class Customers < Grape::API
      resource :customers do
        desc "Get list of customers"
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 10
        end
        get do
          customers = Customer.paginate(page: params[:page], per_page: params[:per_page])

          data = {
            customers: ActiveModelSerializers::SerializableResource.new(
              customers,
              each_serializer: ::CustomerSerializer
            ),
            meta: paginate_meta(customers)
          }

          ok_response data: data
        end
      end
    end
  end
end
