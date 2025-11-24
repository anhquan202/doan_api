module Api
  module Admin
    class Contracts < Grape::API
      helpers do
        params :create_params do
          requires :start_date, type: Date, desc: "Contract start date"
          requires :term_months, type: Integer, desc: "Contract Term in months"
          requires :deposit, type: Float, desc: "Contract deposit"
          requires :room_id, type: Integer, desc: "Room ID"
          requires :customers, type: Array do
            requires :identity_code, type: String
            requires :first_name, type: String
            requires :last_name, type: String
            requires :email, type: String
            requires :phone, type: String
            requires :address, type: String
            requires :gender, type: Integer
            requires :date_of_birth, type: Date
            requires :is_represent, type: Boolean
          end
          requires :utilities, type: Array do
            requires :utility_id, type: Integer
            optional :status, type: Integer
          end
        end
      end

      resources :contracts do
        desc "Create contract"
        params do
          use :create_params
        end
        post do
          ::Admin::CreateContractService.new(params).call
          success_response
        end

        desc "List Contracts (paginated, serializer defines returned attributes)"
        params do
          optional :page, type: Integer, default: 1, desc: "Page number"
          optional :per_page, type: Integer, default: 10, desc: "Items per page"
        end
        get do
          page = params[:page] || 1
          per_page = params[:per_page] || 10

          contracts = ::Contract.paginate(page: page, per_page: per_page)

          data = {
            contracts: ActiveModel::SerializableResource.new(
              contracts,
              each_serializer: ::ContractSerializer
            ),
            meta: paginate_meta(contracts)
          }

          ok_response data: data
        end

        desc "Update term months of the contract"
        params do
          requires :id, type: Integer, desc: "Contract ID"
          requires :term_months, type: Integer, desc: "Contract Term in months"
        end
        patch ":id" do
          contract = ::Contract.find(params[:id])
          Rails.logger.info contract.customers.inspect
          contract.update!(term_months: params[:term_months])
          success_response
        end

        desc "Change status of the contract"
        params do
          requires :id, type: Integer, desc: "Contract ID"
          requires :status, type: String, values: Contract.statuses.keys
        end
        patch ":id/status" do
          contract = ::Contract.find(params[:id])
          contract.update!(status: params[:status])
          success_response
        end
      end
    end
  end
end
