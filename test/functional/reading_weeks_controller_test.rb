require 'test_helper'

class ReadingWeeksControllerTest < ActionController::TestCase
  setup do
    @reading_week = reading_weeks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reading_weeks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reading_week" do
    assert_difference('ReadingWeek.count') do
      post :create, reading_week: @reading_week.attributes
    end

    assert_redirected_to reading_week_path(assigns(:reading_week))
  end

  test "should show reading_week" do
    get :show, id: @reading_week
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @reading_week
    assert_response :success
  end

  test "should update reading_week" do
    put :update, id: @reading_week, reading_week: @reading_week.attributes
    assert_redirected_to reading_week_path(assigns(:reading_week))
  end

  test "should destroy reading_week" do
    assert_difference('ReadingWeek.count', -1) do
      delete :destroy, id: @reading_week
    end

    assert_redirected_to reading_weeks_path
  end
end
