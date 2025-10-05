class ContractUtilitiesController < ApplicationController
  before_action :set_contract_utility, only: %i[ show update destroy ]

  # GET /contract_utilities
  def index
    @contract_utilities = ContractUtility.all

    render json: @contract_utilities
  end

  # GET /contract_utilities/1
  def show
    render json: @contract_utility
  end

  # POST /contract_utilities
  def create
    @contract_utility = ContractUtility.new(contract_utility_params)

    if @contract_utility.save
      render json: @contract_utility, status: :created, location: @contract_utility
    else
      render json: @contract_utility.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /contract_utilities/1
  def update
    if @contract_utility.update(contract_utility_params)
      render json: @contract_utility
    else
      render json: @contract_utility.errors, status: :unprocessable_content
    end
  end

  # DELETE /contract_utilities/1
  def destroy
    @contract_utility.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract_utility
      @contract_utility = ContractUtility.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def contract_utility_params
      params.fetch(:contract_utility, {})
    end
end
