class SuppliesController < ApplicationController
  before_action :set_supply, only: %i[ show update destroy ]

  # GET /supplies
  def index
    @supplies = Supply.all

    render json: @supplies
  end

  # GET /supplies/1
  def show
    render json: @supply
  end

  # POST /supplies
  def create
    @supply = Supply.new(supply_params)

    if @supply.save
      render json: @supply, status: :created, location: @supply
    else
      render json: @supply.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /supplies/1
  def update
    if @supply.update(supply_params)
      render json: @supply
    else
      render json: @supply.errors, status: :unprocessable_content
    end
  end

  # DELETE /supplies/1
  def destroy
    @supply.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supply
      @supply = Supply.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def supply_params
      params.fetch(:supply, {})
    end
end
