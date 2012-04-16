require 'keys.rb'

class UsersController < ApplicationController
	before_filter permission_required(:users), :except => [:login, :logout, :new, :create], :unless => lambda { |c| c.logged_in? && c.current_user.to_param == c.params[:id] }

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
  	@tickets = @user.tickets
  	
  	if @user != current_user
  		@selling = true
  	else
  		@selling = false
  	end
  	
  	@tickets = @tickets.select { |t| t.status == "reserved" }
  	#if !@tickets.empty?
  	#	@invoice = session[:invoice] ? Invoice.find(session[:invoice]) : nil
  	#	if !@invoice
  	#		@invoice = Invoice.make_invoice @tickets
  	#		session[:invoice] = @invoice.id.to_s
  	#	elsif @invoice.tickets != @tickets
  	#		@invoice.update_invoice(@tickets)
  	#	end
  	#end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
  	@user = User.new

  	respond_to do |format|
  		format.html # new.html.erb
  		format.json { render json: @user }
  	end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
	@user.userid = session[:cas_user]
	@user.student_number = params[:user][:student_number]
    @user.student_number_confirmation = params[:user][:student_number_confirmation]

    respond_to do |format|
      if @user.save
		flash[:notice] = 'User was successfully created.'
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def login
    # If a path to return to was set (e.g. by a link leading to the login page),
    # use it. This means that the user is correctly redirected, like login_required.
    store_location params[:return_to] if params[:return_to]

    CASClient::Frameworks::Rails::Filter.filter(self) unless session[:cas_user]

    if session[:cas_user]
      if logged_in?
        redirect_back_or_default(:root)
      else
        login_required
      end
    end
  end

  def logout
    #reset_session
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  
  # GET /users/cart
  # GET /users/cart.json
  def cart
    @curr_user = current_user

    @curr_user.set_prices
    @tickets = @curr_user.reserved_tickets
    @price = 0.00

    @tickets.each do |tick|
      @price = @price + tick.ticket_price
    end

    # If an invoice is not created then one must be created
    # If one is created then it is updated
    invoices = Invoice.where(:status => 'unpaid', :user_id => @curr_user.id)
    if invoices.size == 0
      @invoice = Invoice.make_invoice @tickets
    elsif invoices.size == 1
      @invoice = invoices[0].update_invoice @tickets
    else
      # There should never be more than one active invoice for a user
      # ERROR WHAT NOW BITCH?
    end

    @amount = (@price * 100).to_i.to_s
    @timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    @merchant_id = Keys.merchant_id
    @hash = Digest::SHA1.hexdigest(@invoice.id.to_s + '|' + @amount + '|' + @timestamp + '|' + Keys.admeris_hash)

  end
end
