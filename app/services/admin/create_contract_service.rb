# DEPRECATED: Use Admin::ContractWizard services instead
# This service is kept for backward compatibility with the old single-step API
# New wizard flow:
#   - Step 1: Admin::ContractWizard::Step1CustomersService (create customers with vehicles)
#   - Step 2: Admin::ContractWizard::Step2TermService (set rental term)
#   - Step 3: Admin::ContractWizard::Step3CompleteService (finalize contract)
class Admin::CreateContractService
  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      contract = Contract.create!(
        start_date: @params[:start_date],
        term_months: @params[:term_months],
        deposit: @params[:deposit],
        room_id: @params[:room_id],
        status: :active
      )

      # create customers and join table
      @params[:customers].each do |cus|
        # Build vehicle_data JSON if present
        vehicle_json = nil
        if cus[:vehicle].present?
          vehicle = Vehicle.find_by(id: cus[:vehicle][:vehicle_id])
          vehicle_json = {
            vehicle_id: cus[:vehicle][:vehicle_id],
            vehicle_name: vehicle&.name,
            plate_number: cus[:vehicle][:plate_number]
          }
        end

        customer = Customer.create!(
          identity_code: cus[:identity_code],
          first_name: cus[:first_name],
          last_name: cus[:last_name],
          email: cus[:email],
          phone: cus[:phone],
          address: cus[:address],
          gender: cus[:gender],
          date_of_birth: cus[:date_of_birth],
          status: :active,
          vehicle_data: vehicle_json
        )

        ContractCustomer.create!(
          contract_id: contract.id,
          customer_id: customer.id,
          is_represent: cus[:is_represent],
          move_in_date: @params[:start_date]
        )
      end

      room = Room.find(@params[:room_id])
      room.update!(status: :occupied)

      contract
    end
  end
end
