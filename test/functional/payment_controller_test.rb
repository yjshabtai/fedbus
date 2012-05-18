require 'test_helper'

class PaymentControllerTest < ActionController::TestCase
  test "should get cart" do
    get :cart
    assert_response :success
  end

  test "should get payinfo" do
    get :payinfo
    assert_response :success
  end

  test "should get response" do
    get :response
    assert_response :success
  end

end
