class ContractCustomersController < ApplicationController
  before_action :set_contract_customer, only: %i[ show update destroy ]

  # GET /contract_customers
  def index
    @contract_customers = ContractCustomer.all

    render json: @contract_customers
  end

  # GET /contract_customers/1
  def show
    render json: @contract_customer
  end

  # POST /contract_customers
  def create
    @contract_customer = ContractCustomer.new(contract_customer_params)

    if @contract_customer.save
      render json: @contract_customer, status: :created, location: @contract_customer
    else
      render json: @contract_customer.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /contract_customers/1
  def update
    if @contract_customer.update(contract_customer_params)
      render json: @contract_customer
    else
      render json: @contract_customer.errors, status: :unprocessable_content
    end
  end

  # DELETE /contract_customers/1
  def destroy
    @contract_customer.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract_customer
      @contract_customer = ContractCustomer.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def contract_customer_params
      params.fetch(:contract_customer, {})
    end
end
