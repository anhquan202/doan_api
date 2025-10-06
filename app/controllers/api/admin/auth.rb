module Api
  module Admin
    class Auth < Grape::API
      resource :auth do
        desc "Admin sign up"
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :phone, type: String, allow_blank: false
          requires :address, type: String, allow_blank: false
          requires :gender, type: String, values: [ "male", "female", "other" ]
          requires :date_of_birth, type: Date
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          requires :password_confirmation, type: String, same_as: :password
        end

        post "sign_up" do
          result = ::Admin::SignupService.new(params).call
          ok_response(data: { token: result })
        end
      end
    end
  end
end
