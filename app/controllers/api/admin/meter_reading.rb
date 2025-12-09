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

    desc "Get meter readings for all contracts with pagination and filters"
    params do
      optional :page, type: Integer, default: 1, desc: "Page number"
      optional :per_page, type: Integer, default: 10, desc: "Items per page"
      optional :month, type: Integer, desc: "Month (1-12), default: current month - 1"
      optional :year, type: Integer, desc: "Year, default: current year"
    end
    get do
      current_date = Date.today
      default_month = current_date.month - 1
      default_year = current_date.year

      if default_month == 0
        default_month = 12
        default_year -= 1
      end

      month = params[:month] || default_month
      year = params[:year] || default_year
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      # Get contract IDs that have readings for the specified month and year
      contract_ids = ::Contract
        .joins(:electric_readings, :water_readings)
        .where(
          "electric_readings.month = ? AND electric_readings.year = ? OR water_readings.month = ? AND water_readings.year = ?",
          month, year, month, year
        )
        .distinct
        .pluck(:id)

      # Fetch contracts with proper eager loading to prevent N+1
      contracts = ::Contract
        .where(id: contract_ids)
        .includes(:utilities, :electric_readings, :water_readings)
        .paginate(page: page, per_page: per_page)

      data = {
        meter_readings: ActiveModelSerializers::SerializableResource.new(
          contracts,
          each_serializer: ::MeterReadingSerializer,
          month: month,
          year: year
        ),
        meta: paginate_meta(contracts, per_page)
      }

      ok_response data: data
    end
  end
end
