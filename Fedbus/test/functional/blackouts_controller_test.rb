require 'test_helper'

class BlackoutsControllerTest < ActionController::TestCase
  setup do
    @blackout = blackouts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blackouts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create blackout" do
    assert_difference('Blackout.count') do
      post :create, blackout: @blackout.attributes
    end

    assert_redirected_to blackout_path(assigns(:blackout))
  end

  test "should show blackout" do
    get :show, id: @blackout
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @blackout
    assert_response :success
  end

  test "should update blackout" do
    put :update, id: @blackout, blackout: @blackout.attributes
    assert_redirected_to blackout_path(assigns(:blackout))
  end

  test "should destroy blackout" do
    assert_difference('Blackout.count', -1) do
      delete :destroy, id: @blackout
    end

    assert_redirected_to blackouts_path
  end
end
