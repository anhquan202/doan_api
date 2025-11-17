module Api
  module Admin
    class Contracts < Grape::API
      resources :contracts do
        desc "Create contract"
        params do
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
        post do
          ::Admin::CreateContractService.new(params).call
          success_response
        end
      end
    end
  end
end
