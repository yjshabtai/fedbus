require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  setup do
    @invoice = invoices(:one)
  end

  test "should not get index for unauthenticated user" do
    get :index
    assert_response :redirect
  end

	test "should not get index for authenticated user without the invoices permission" do
		@request.session[:userid] = users(:one).userid
		get :index
		assert_response :forbidden
	end

	test "should get index for user with invoices permission" do
		with_permission :invoices
		get :index
		assert_response :success
	end

  test "should not show invoice for unauthenticated user" do
    get :show, :id => invoices(:one).to_param
    assert_response :redirect
  end

	test "should not show invoice for authenticated user without the invoices permission" do
		@request.session[:userid] = users(:one).userid
		get :show, :id => invoices(:one).to_param
		assert_response :forbidden
	end

	test "should show invoice for user with invoices permission" do
		with_permission :invoices
		get :show, :id => invoices(:one).to_param
		assert_response :success
	end

  test "should not get edit for unauthenticated user" do
    get :edit, :id => invoices(:one).to_param
    assert_response :redirect
  end

	test "should not get edit for authenticated user without the invoices permission" do
		@request.session[:userid] = users(:one).userid
		get :edit, :id => invoices(:one).to_param
		assert_response :forbidden
	end

	test "should get edit for user with the invoices permission" do
		with_permission :invoices
		get :edit, :id => invoices(:one).to_param
		assert_response :success
	end

  test "should not update invoice for unauthenticated user" do
    put :update, :id => invoices(:one).id, :invoice => { :total => 9.98, :status => :paid, :user_id => 1 }
		assert Invoice.find(invoices(:one).id).status == invoices(:one).status
    assert_response :redirect
  end

	test "should not update invoice for authenticated user without the invoices permission" do
		@request.session[:userid] = users(:one).userid
		put :update, :id => invoices(:one).to_param, :invoice => { }
		assert_response :forbidden
	end

	test "should update invoice for user with invoices permission" do
		with_permission :invoices
		put :update, :id => invoices(:one).to_param, :invoice => invoices(:two)
		assert_redirected_to invoice_path(assigns(:invoice))
	end

end
