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

        desc "Get customer by ID"
        params do
          requires :id, type: Integer, desc: "Customer ID"
        end
        get ":id" do
          customer = Customer.includes(contract: :room).find params[:id]

          data = {
            customer: ::CustomerDetailSerializer.new(customer)
          }

          ok_response data: data
        end

        desc "Update customer information"
        params do
          requires :id, type: Integer, desc: "Customer ID"
          requires :email, type: String, desc: "Email"
          requires :phone, type: String, desc: "Phone"
          requires :address, type: String, desc: "Address"
        end
        patch ":id" do
          customer = Customer.find(params[:id])

          customer.update!(email: params[:email], phone: params[:phone], address: params[:address], status: params[:status])

          success_response
        end
      end
    end
  end
end
