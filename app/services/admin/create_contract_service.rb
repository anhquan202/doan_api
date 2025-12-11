class Admin::CreateContractService
  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      contract = Contract.create!(
        start_date: @params[:start_date],
        term_months:   @params[:term_months],
        deposit:    @params[:deposit],
        room_id:    @params[:room_id],
        status:     :active
      )

      # create customers and join table
      @params[:customers].each do |cus|
        customer = Customer.create!(
          identity_code: cus[:identity_code],
          first_name: cus[:first_name],
          last_name: cus[:last_name],
          email: cus[:email],
          phone: cus[:phone],
          address: cus[:address],
          gender: cus[:gender],
          date_of_birth: cus[:date_of_birth],
          status: 1
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
