class Api::Admin::MeterReading < Grape::API
  before { authenticate_admin! }

  resources :meter_reading do
    desc "Import meter reading from XLSX file"
    params do
      requires :meter_file, type: File, desc: "XLSX file"
    end
    post "import/xlsx" do
      data = ::Admin::ImportMeterReadingXlsxService.new(params[:meter_file]).call

      ok_response data: data
    end
  end
end
