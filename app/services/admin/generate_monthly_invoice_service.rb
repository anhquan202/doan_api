module Admin
  class GenerateMonthlyInvoiceService
    def initialize(contract_id:, month:, year:)
      @contract = Contract.find(contract_id)
      @month = month
      @year = year
    end

    def call
      ActiveRecord::Base.transaction do
        invoice = MonthlyInvoice.find_or_initialize_by(
          contract_id: @contract.id,
          month: @month,
          year: @year
        )

        # Chỉ cập nhật nếu chưa thanh toán
        return invoice if invoice.persisted? && invoice.paid?

        invoice.assign_attributes(
          room_fee: calculate_room_fee,
          electric_fee: calculate_electric_fee,
          water_fee: calculate_water_fee,
          service_fee: calculate_service_fee,
          service_details: build_service_details,
          status: invoice.status || :pending
        )

        invoice.save!
        invoice
      end
    end

    private

    def calculate_room_fee
      @contract.room.price || 0
    end

    def calculate_electric_fee
      reading = @contract.electric_readings.find_by(month: @month, year: @year)
      reading&.total_fee || 0
    end

    def calculate_water_fee
      reading = @contract.water_readings.find_by(month: @month, year: @year)
      reading&.total_fee || 0
    end

    def calculate_service_fee
      active_utilities.sum { |cu| (cu.utility.fee || 0) * (cu.quantity || 1) }
    end

    def build_service_details
      active_utilities.map do |cu|
        fee = cu.utility.fee || 0
        quantity = cu.quantity || 1
        {
          utility_id: cu.utility_id,
          utility_type: cu.utility.utility_type,
          utility_name: cu.utility.utility_type_label,
          fee: fee,
          quantity: quantity,
          subtotal: fee * quantity
        }
      end
    end

    def active_utilities
      @active_utilities ||= @contract.contract_utilities
                                     .where(status: :active)
                                     .includes(:utility)
                                     .where.not(utilities: { utility_type: [:electricity, :water] })
    end
  end
end

