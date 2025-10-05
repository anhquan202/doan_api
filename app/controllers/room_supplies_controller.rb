class RoomSuppliesController < ApplicationController
  before_action :set_room_supply, only: %i[ show update destroy ]

  # GET /room_supplies
  def index
    @room_supplies = RoomSupply.all

    render json: @room_supplies
  end

  # GET /room_supplies/1
  def show
    render json: @room_supply
  end

  # POST /room_supplies
  def create
    @room_supply = RoomSupply.new(room_supply_params)

    if @room_supply.save
      render json: @room_supply, status: :created, location: @room_supply
    else
      render json: @room_supply.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /room_supplies/1
  def update
    if @room_supply.update(room_supply_params)
      render json: @room_supply
    else
      render json: @room_supply.errors, status: :unprocessable_content
    end
  end

  # DELETE /room_supplies/1
  def destroy
    @room_supply.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room_supply
      @room_supply = RoomSupply.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def room_supply_params
      params.fetch(:room_supply, {})
    end
end
