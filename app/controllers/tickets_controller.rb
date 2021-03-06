require 'keys.rb'

class TicketsController < ApplicationController
	
	# TODO: Document the control flow for buying and selling tickets here
	
	before_filter permission_required(:tickets_sell), :only => [:sell]
	before_filter :login_required, :only => [:buy]
	
	def is_own_ticket?
		logged_in? && Ticket.find(params[:id]).user == current_user
	end
	
	# POST /tickets/reserve
	def reserve
		# Get post data
		bus = Bus.find(params[:dep_id])
		dir = params[:from_uw] == 'true' ? "from_waterloo" : "to_waterloo"
		buying = params[:buying] == 'true' ? true : false
		all_returns = bus.find_returns

		# Get returning data
		returning = false
		bus_r = 0
		dir_r = ""
		if params[:ret] == 'true'
			returning = true
			bus_r = Bus.find(params[:ret_id])
			dir_r = dir == "from_waterloo" ? "to_waterloo" : "from_waterloo"

			# If the user cheated with the post data then disallow it
			if !all_returns.include?(bus_r)
				# error render partial tickets/doesn'texist
			end
		end

		curr_user = current_user
		@errors = []
		@tickets = []

		# Is the ticket being sold by a vendor or being purchased online?
		if !buying #&& curr_user.has_permission?(:ticket_selling)
			#Log.make_log "Beginning sale of tickets", "User", buyer, curr_user.id

			render :partial => "tickets/reserve"
		else
			Log.make_log "Began reserving of tickets", "User", curr_user.id, curr_user.id

			active_tickets = curr_user.tickets_for_date(bus.date)
			active_tickets_r = returning ? curr_user.tickets_for_date(bus_r.date) : []

			if !active_tickets.empty?
				# Iff one active ticket is on this day and
				# The active ticket's bus is a valid return bus or
				# 	the active ticket's bus' valid return buses include the to be purchased ticket and
				#   there are no more tickets being purchased
				# then the new ticket can be reserved
				if (active_tickets.length == 1 && 
					( all_returns.include?(active_tickets[0].bus) ||
						( active_tickets[0].bus.find_returns.include?(bus) &&
						!returning )
					)) == false
					@errors << "You already have a ticket on #{bus.date.strftime("%a, %B %e")}"
					Log.make_log "Tried to buy an invalid ticket", "User", curr_user.id, curr_user.id
				end
			end

			# You can not return from somewhere and then have another ticket on the same day if that ticket is not what the return ticket is returning from
			if !active_tickets_r.empty?
				@errors << "You already have a ticket on #{bus_r.date.strftime("%a, %B %e")}"
				Log.make_log "Tried to buy an invalid ticket", "User", curr_user.id, curr_user.id
			end

			# If there are no errors then the tickets are reserved
			if @errors.empty?
				ticket = Ticket.make_ticket curr_user, bus, dir
				@tickets << ticket

				if returning
					ticket_r = Ticket.make_ticket curr_user, bus_r, dir_r
					ticket.return_ticket = ticket_r
					ticket.save
					@tickets << ticket_r
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
  
  	# GET /tickets/sell
  	# GET /tickets/sell.json
  	def sell
  		
  	end
  
	# GET /tickets/buy
	# GET /tickets/buy.json
	def buy
		@dates = Bus.where(:status => :open).select{|b| !b.maximum_seats || b.available_tickets('from_waterloo') > 0 || b.available_tickets('to_waterloo') > 0 }.collect {|b| b.date }.uniq
		@gmapkey = Keys.gmap
	end

	def find_user

		student_num_hash = Digest::SHA256.hexdigest(params[:student_num])
		@user = User.find_by_student_number_hash(student_num_hash)
		
		@dates = Bus.where(:status => :open).collect {|b| b.date }.uniq

		@user ? (render :partial => "tickets/selling1") : (render :text => 'false')
	end

	def find_dests

		if params[:dep_id] == '0'
			@destinations = Bus.where(:date => params[:date], :status => :open).select{|b| !b.maximum_seats || b.available_tickets('from_waterloo') > 0}.collect {|b| [b.destination.name + ', ' + b.arrive_time.strftime("%k:%M"), b.id]}
		else
			bus = Bus.find(params[:dep_id])
			@destinations = [['UW Campus, ' + bus.return_time.strftime("%k:%M"), bus.id]]
		end

		params[:buying] == 'true' ? (render :partial => "tickets/buying3") : (render :partial => "tickets/selling3")
	end

    # Gets the ticket data for the given bus info and renders the ticket info partial
	def ticket_data

		@bus = Bus.find(params[:bus_id])
		@destination = @bus.destination
		@arrive = (params[:dep_id] == '0') ? @bus.arrive_time : @bus.return_time
		@depart = params[:dep_id] == '0' ? @bus.depart_time : @bus.arrive_time
		@ticks_avail = params[:dep_id] == '0' ? @bus.available_tickets('from_waterloo') : @bus.available_tickets('to_waterloo')

		@return_dates = @bus.find_returns(params[:dep_id] == '0' ? true : false).select{|rb| !rb.maximum_seats || rb.available_tickets(params[:dep_id] == '0' ? 'to_waterloo' : 'from_waterloo') > 0}.collect{|rb| rb.date}.uniq

		params[:buying] == 'true' ? (render :partial => "tickets/buying4") : (render :partial => "tickets/selling4")
	end

	# Gets the locations for departure on a given date
	def find_deps
		# This will list all of the buses with departures on this date.
		# There will be at least one because the date selector uses a similar formula.
		@departures = [['UW Campus', 0]] + (Bus.where(:date => params[:date], :status => :open).select{|b| !b.maximum_seats || b.available_tickets('to_waterloo') > 0}.collect {|b| [b.destination.name + ', ' + b.arrive_time.strftime("%k:%M"), b.id]})

		params[:buying] == 'true' ? (render :partial => "tickets/buying2") : (render :partial => "tickets/selling2")
	end

	# Gets the return buses for the given bus and date
	def find_returns
		bus = Bus.find(params[:bus_id])
		@return_buses = bus.find_returns(params[:dep_id] == '0' ? true : false).select{|rb| (!rb.maximum_seats || rb.available_tickets(params[:dep_id] == '0' ? 'to_waterloo' : 'from_waterloo') > 0) && rb.date == params[:ret_date].to_date}.collect{|rb| [(params[:dep_id] != '0' ? 'UW Campus' : rb.destination.name) + ', ' + ((params[:dep_id] == '0') ? rb.arrive_time.strftime("%k:%M") : rb.depart_time.strftime("%k:%M")), rb.id]}

		render :partial => "tickets/buying5"
	end

	# Gets the chosen return bus' info
	def ticket_data_r
		@bus_r = Bus.find(params[:rb_id])
		@destination_r = @bus_r.destination
		@arrive_r = (params[:dep_id] == '0') ? @bus_r.return_time : @bus_r.arrive_time
		@depart_r = (params[:dep_id] == '0') ? @bus_r.arrive_time : @bus_r.depart_time
		@ticks_avail_r = params[:dep_id] == '0' ? @bus_r.available_tickets('to_waterloo') : @bus_r.available_tickets('from_waterloo')

		render :partial => "tickets/buying6"
	end

	# Gets the price of the ticket to be purchased if return trip is selected
	def update_price
		bus = Bus.find(params[:bus_id])
		@ticket_price = params[:ret] == 'true' ? ((bus.ticket_price - 1.0) + (Bus.find(params[:rbus_id]).ticket_price - 1.0)) : bus.ticket_price

		render :partial => "tickets/ticketprice"
	end
end
