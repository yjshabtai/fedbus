class TicketsController < ApplicationController
	
	# TODO: Document the control flow for buying and selling tickets here
	
	before_filter permission_required(:tickets_sell), :only => [:sell]
	before_filter :login_required, :only => [:buy]
	
	def is_own_ticket?
		logged_in? && Ticket.find(params[:id]).user == current_user
	end
  
	# GET /tickets/buy
	# GET /tickets/buy.json
	def buy
		@dates = Bus.where(:status => :open).collect {|b| b.date }.uniq
	end
	
	# POST /tickets/reserve
	def reserve
		# Get post data
		dir = params[:dep_id] == '0' ? :from_waterloo : :to_waterloo
		bus = Bus.find(params[:bus_id])
		return_bus = params[:ret] == 'true' ? bus.find_return : false
		buying = params[:buying] == 'true' ? true : false
		
		curr_user = current_user
		@errors = []
		@tickets = []

		# Is the ticket being sold by a vendor or being bought online?
		if !buying && curr_user.has_permission?(:ticket_selling)

		else
			if !curr_user.tickets_for_date(bus.date).empty?
				@errors << "You already have a ticket on " + bus.date.to_s
			end
			if return_bus && !curr_user.tickets_for_date(return_bus.date).empty?
				@errors << "You already have a ticket on " + return_bus.date.to_s
			end

			if @errors.empty?
				@tickets << Ticket.make_ticket(curr_user, bus, dir)
				if return_bus
					@tickets << Ticket.make_ticket(curr_user, return_bus, (params[:dep_id] == '0' ? :to_waterloo : :from_waterloo))
					@tickets.each do |tick|
						tick.ticket_price = tick.bus.ticket_price - 1.0
						tick.save
					end
				end
			end

			render :partial => "tickets/reserve"
		end

	end

	# GET /tickets/pay
	def pay


	end

	# GET /tickets/pay_area
	def pay_area
	end
		#if params[:departure] == '0'
		#	dir = :from_waterloo
		#else
		#	dir = :to_waterloo
		#end
		#@errors = nil
		#@tickets_on_date = []
		#@tickets = []
		#
		#if params[:departure] == '0'
		#	dir2 = :to_waterloo
		#else
		#	dir2 = :from_waterloo
		#end
		#
		#bus = Bus.find(params[:bus][:id])
		#date = bus.date
		#
		#return_trip = true unless params[:trip][:return] != '1'
		#
		## TODO: Don't name vars X2, name them X_return, more verbose, but #fewer WTF/min
		#if return_trip
		#	buses_for_bus2 = Bus.where("destination_id = ? and date >= ?", bus.#destination_id, bus.date + 1.days)
		#	if buses_for_bus2.length == 1
		#		bus2 = buses_for_bus2[0]
		#	else
		#		bus2 = (buses_for_bus2.inject { |d1, d2| d1.date <= d2.date ? #d1 : d2 })
		#	end
		#	# TODO: Why is this bus2 and not something like bus2.date?  #Explain or fix
		#	date2 = bus2
		#end
		#
		#user =
		#	if current_user.has_permission?(:ticket_selling) && params[:student#] && params[:student] != ""
		#		User.find(params[:student])
		#	else
		#		current_user
		#	end
		#	
		#if user.tickets_for_date(date).count > 0
		#	@errors = "You already have a ticket on " + date.to_s
		#	return
		#end
		#
		#if return_trip && user.tickets_for_date(date2).count > 0
		#	@errors = "You already have a ticket on " + date2.to_s
		#	return
		#end
		#
		#new_ticket = Ticket.make_ticket(user, bus, dir, (user == current_user ?# nil : current_user))
		#if return_trip
		#	new_ticket.ticket_price = bus.ticket_price - 1
		#	new_ticket.save
		#	
		#	new_ticket2 = Ticket.make_ticket(user, bus2, dir2, (user == #current_user ? nil : current_user))
		#	new_ticket2.ticket_price = bus2.ticket_price - 1
		#	new_ticket2.save
		#	@tickets << new_ticket2
		#end
		#@tickets << new_ticket
		#
		#redirect_to user_path(user)
	#end


  
  	# GET /tickets/sell
  	# GET /tickets/sell.json
  	def sell
  		
  	end

	def find_user

		student_num_hash = Digest::SHA256.hexdigest(params[:student_num])
		@user = User.find_by_student_number_hash(student_num_hash)
		
		@dates = Bus.where(:status => :open).collect {|b| b.date }.uniq

		@user ? (render :partial => "tickets/selling1") : (render :text => 'false')
	end

	def find_dests

		if params[:dep_id] == '0'
			@destinations = Bus.where(:date => params[:date], :status => :open).collect {|b| [b.destination.name + ', ' + b.arrive_time.strftime("%k:%M"), b.id]}
		else
			bus = Bus.where(:date => params[:date], :status => :open, :destination_id => params[:dep_id]).first
			@destinations = [['UW Campus, ' + bus.return_time.strftime("%k:%M"), bus.id]]
		end

		params[:buying] == 'true' ? (render :partial => "tickets/buying3") : (render :partial => "tickets/selling3")
	end

    # Gets the ticket data for the given bus info and renders the ticket info partial
	def ticket_data

		@bus = Bus.find(params[:bus_id])
		@arrive = (params[:dep_id] == '0') ? @bus.arrive_time : @bus.return_time
		@depart = params[:dep_id] == '0' ? @bus.depart_time : @bus.arrive_time
		
		@return_buses = params[:dep_id] == '0' ? (@bus.find_returns.collect {|rb| [rb.destination.name + ', ' + rb.depart_time.strftime("%k:%M"), rb.id]}) : [['UW Campus', 0]]

		params[:buying] == 'true' ? (render :partial => "tickets/buying4") : (render :partial => "tickets/selling4")
	end

	# Gets the locations for departure on a given date
	def find_deps
		@departures = [['UW Campus', 0]] + (Bus.where(:date => params[:date], :status => :open).collect {|b| [b.destination.name + ', ' + b.arrive_time.strftime("%k:%M"), b.destination.id]})

		params[:buying] == 'true' ? (render :partial => "tickets/buying2") : (render :partial => "tickets/selling2")
	end

	# Gets the price of the ticket to be purchased if return trip is selected
	def update_price
		bus = Bus.find(params[:bus_id])
		@ticket_price = params[:ret] == 'true' ? ((bus.ticket_price - 1.0) * 2.0) : bus.ticket_price

		render :partial => "tickets/ticketprice"
	end
end
