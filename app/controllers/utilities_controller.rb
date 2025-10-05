class UtilitiesController < ApplicationController
  before_action :set_utility, only: %i[ show update destroy ]

  # GET /utilities
  def index
    @utilities = Utility.all

    render json: @utilities
  end

  # GET /utilities/1
  def show
    render json: @utility
  end

  # POST /utilities
  def create
    @utility = Utility.new(utility_params)

    if @utility.save
      render json: @utility, status: :created, location: @utility
    else
      render json: @utility.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /utilities/1
  def update
    if @utility.update(utility_params)
      render json: @utility
    else
      render json: @utility.errors, status: :unprocessable_content
    end
  end

  # DELETE /utilities/1
  def destroy
    @utility.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_utility
      @utility = Utility.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def utility_params
      params.fetch(:utility, {})
    end
end
