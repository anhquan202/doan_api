module Api
  module Admin
    class Root < Grape::API
      prefix :api
      version "v1", using: :path
      format :json

      mount Api::Admin::Auth
      mount Api::Admin::Room
    end
  end
end
