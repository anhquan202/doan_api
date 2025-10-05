require "test_helper"

class ContractUtilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contract_utility = contract_utilities(:one)
  end

  test "should get index" do
    get contract_utilities_url, as: :json
    assert_response :success
  end

  test "should create contract_utility" do
    assert_difference("ContractUtility.count") do
      post contract_utilities_url, params: { contract_utility: {} }, as: :json
    end

    assert_response :created
  end

  test "should show contract_utility" do
    get contract_utility_url(@contract_utility), as: :json
    assert_response :success
  end

  test "should update contract_utility" do
    patch contract_utility_url(@contract_utility), params: { contract_utility: {} }, as: :json
    assert_response :success
  end

  test "should destroy contract_utility" do
    assert_difference("ContractUtility.count", -1) do
      delete contract_utility_url(@contract_utility), as: :json
    end

    assert_response :no_content
  end
end
