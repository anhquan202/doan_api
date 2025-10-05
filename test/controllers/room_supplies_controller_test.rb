require "test_helper"

class RoomSuppliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room_supply = room_supplies(:one)
  end

  test "should get index" do
    get room_supplies_url, as: :json
    assert_response :success
  end

  test "should create room_supply" do
    assert_difference("RoomSupply.count") do
      post room_supplies_url, params: { room_supply: {} }, as: :json
    end

    assert_response :created
  end

  test "should show room_supply" do
    get room_supply_url(@room_supply), as: :json
    assert_response :success
  end

  test "should update room_supply" do
    patch room_supply_url(@room_supply), params: { room_supply: {} }, as: :json
    assert_response :success
  end

  test "should destroy room_supply" do
    assert_difference("RoomSupply.count", -1) do
      delete room_supply_url(@room_supply), as: :json
    end

    assert_response :no_content
  end
end
