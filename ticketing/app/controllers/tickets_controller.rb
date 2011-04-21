class TicketsController < ApplicationController
	before_filter permission_required(:tickets), :except => [:show, :buy, :sell]
	before_filter permission_required(:tickets), :only => [:show],
     	            :unless => lambda { |c| c.logged_in? && 
									           c.current_user == Ticket.find(c.params[:id]).user }
	before_filter :login_required, :only => [:buy]
	before_filter permission_required(:ticket_selling), :only => [:sell]

  # GET /tickets
  # GET /tickets.xml
  def index
    @tickets = Ticket.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tickets }
    end
  end

  # GET /tickets/1
  # GET /tickets/1.xml
  def show
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ticket }
    end
  end

  # GET /tickets/new
  # GET /tickets/new.xml
  def new
    @ticket = Ticket.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ticket }
    end
  end

  # GET /tickets/1/edit
  def edit
    @ticket = Ticket.find(params[:id])
  end

  # POST /tickets
  # POST /tickets.xml
  def create
    @ticket = Ticket.new(params[:ticket] )

    respond_to do |format|
      if @ticket.valid?
				if TicketLog.make_log(params[:log], @ticket, current_user)
					@ticket.save
					flash[:notice] = 'Ticket was successfully created.'
					format.html { redirect_to(@ticket) }
					format.xml  { render :xml => @ticket, :status => :created, :location => @ticket }
				else
					@ticket.errors.add :log, "entry cannot be blank"
					format.html { render :action => "new" }
					format.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
				end
      else
				@ticket.save
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tickets/1
  # PUT /tickets/1.xml
  def update
    @ticket = Ticket.find(params[:id])

		@ticket.attributes = params[:ticket]

    respond_to do |format|
      if @ticket.valid?
				if TicketLog.make_log(params[:log], @ticket, current_user)
					@ticket.save
					flash[:notice] = 'Ticket was successfully updated.'
					format.html { redirect_to(@ticket) }
					format.xml  { head :ok }
				else
					@ticket.errors.add :log, "entry cannot be blank"
					format.html { render :action => "edit" }
					format.xml { render :xml => @ticket.errors, :status => :unprocessable_entity }
				end
      else
				@ticket.save
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.xml
  def destroy
    #@ticket = Ticket.find(params[:id])
    #@ticket.destroy

    #respond_to do |format|
    #  format.html { redirect_to(tickets_url) }
    #  format.xml  { head :ok }
    #end
		
		redirect_to(tickets_url)
  end

	def reserve
		dir = params[:direction]
		@dirs = [:from_waterloo, :to_waterloo]
		@dirs.reverse! if dir.to_i == 1

		@errors = nil
		@tickets_on_date = []
		@tickets = []

		@buses = [params[:zero_select].to_i, params[:one_select].to_i]

		if @buses[0] != 1 and @buses[1] != 1
			flash[:error] = "Please select at least one destination"
			#redirect_to root_path(:opposite => dir, :student => params[:student]) 
			return
		else
			user =
				if current_user.has_permission?(:ticket_selling) and 
						params[:student] and params[:student] != ""
					User.find params[:student]
				else
					current_user
				end

			@buses.each_with_index do |b, i|
				if b != 1 
					next
				end

				id = params["ticket_#{i.to_s}".to_sym][:id]

				if id.empty?
					flash[:error] = "Please choose a bus for your selection '#{@dirs[i].to_s.humanize.downcase}'"
					redirect_to root_path(:opposite => dir, :student => params[:student])
					return
				end

				bus = Bus.find id.to_i
				date = bus.departure.to_date

				if(!(@tickets_on_date = current_user.tickets_for_date(date)).empty?)
					@errors = "You already have a ticket on " + date.to_s
					return
				end

				# If user != current_user, then someone is selling the ticket
				@tickets << Ticket.make_ticket(user, bus, @dirs[i], (user == current_user ? nil : current_user))
			end
		end

		redirect_to user_tickets_path(:user_id => user.id, :selling => (user == current_user ? nil : "1"))

	end

	def expire
		@expired = Ticket.expire
	end

	def buy
		if current_user.has_permission?(:ticket_selling)
			@student =
				if params[:selling] == "1"
					User.find_by_student_number params[:student_number]
				elsif params[:student] and params[:student] != ""
					User.find params[:student]
				end

			if !@student and params[:selling] == "1"
				flash[:error] = "Could not find the student with that student number." 
				redirect_to sell_tickets_path
				return
			end
		end

		@earliestdate = Bus.earliest_date_after Date.today

		@otherdir = params[:opposite] == "1"

		@forward = Bus.on_date_in_direction @earliestdate, (@otherdir ? :to_waterloo : :from_waterloo)
		@backward = Bus.after_date_in_direction @earliestdate, (@otherdir ? :from_waterloo : :to_waterloo)

		@dayto = @forward[0] ? @forward[0].departure.strftime("%A") : nil
		@dayfrom = @backward[0] ? @backward[0].departure.strftime("%A") : nil
	end

	def recent
		# Default value is in the past day
		@time = params[:time] ? Time.at(params[:time].to_i) : Time.now - 86400
		@recent = Ticket.where ["updated_at >= ?", @time]

		respond_to do |format|
			format.html
			format.xml
		end
	end

	def sell

	end

end
