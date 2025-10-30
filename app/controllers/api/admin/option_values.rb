module Api
  module Admin
    class OptionValues < Grape::API
      resource :option_values do
        resources :supplies do
          desc "Get supply unit options"
          get "/unit" do
            data = Supply.units.map do |key, _|
              {
                key: key,
                value: I18n.t("enums.supply.unit.#{key}")
              }
            end

            ok_response data: data
          end
        end
      end
    end
  end
end
