require "test_helper"

class ContractCustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contract_customer = contract_customers(:one)
  end

  test "should get index" do
    get contract_customers_url, as: :json
    assert_response :success
  end

  test "should create contract_customer" do
    assert_difference("ContractCustomer.count") do
      post contract_customers_url, params: { contract_customer: {} }, as: :json
    end

    assert_response :created
  end

  test "should show contract_customer" do
    get contract_customer_url(@contract_customer), as: :json
    assert_response :success
  end

  test "should update contract_customer" do
    patch contract_customer_url(@contract_customer), params: { contract_customer: {} }, as: :json
    assert_response :success
  end

  test "should destroy contract_customer" do
    assert_difference("ContractCustomer.count", -1) do
      delete contract_customer_url(@contract_customer), as: :json
    end

    assert_response :no_content
  end
end
