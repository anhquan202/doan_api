module Api
  module Admin
    class Root < Grape::API
      prefix :api
      version "v1", using: :path
      format :json

      mount Api::Admin::Auth
    end
  end
end
