module Admin
  class GenerateBulkMonthlyInvoicesService
    def initialize(month:, year:)
      @month = month
      @year = year
    end

    def call
      results = { success: [], errors: [] }

      Contract.active.includes(:room).find_each do |contract|
        begin
          invoice = Admin::GenerateMonthlyInvoiceService.new(
            contract_id: contract.id,
            month: @month,
            year: @year
          ).call

          results[:success] << {
            contract_id: contract.id,
            contract_code: contract.contract_code,
            room_name: contract.room_name,
            invoice_id: invoice.id,
            total_amount: invoice.total_amount,
            status: invoice.status
          }
        rescue => e
          results[:errors] << {
            contract_id: contract.id,
            contract_code: contract.contract_code,
            error: e.message
          }
        end
      end

      results
    end
  end
end

