class Bus < ActiveRecord::Base
	STATUSES = [:open, :locked]
	DIRECTIONS = [:both_directions, :from_waterloo, :to_waterloo]

	has_many :tickets
	belongs_to :trip
	belongs_to :destination

	validates_presence_of :name, :trip, :date, :direction, :status
	
	# Updates a new bus with trip info and default bus info
	def create_bus_from_trip trip, dep_date
		self.update_trip_info trip
		self.description = "Created automatically by system."
		self.date = dep_date
		self.direction = :both_directions
		self.status = :open
		self.trip = trip
	end

	# All of the trip information is updated from a given trip
	def update_trip_info trip
		self.name = trip.name
		self.depart_time = trip.depart_time
		self.arrive_time = trip.arrive_time
		self.return_time = trip.return_time
		self.ticket_price = trip.ticket_price
		self.sales_lead = trip.sales_lead
		self.destination = trip.destination
	end

	# Maximizes the number of seats for after Wednesday bus ordering
	def maximize_seats
		# the number of seats per bus and how many buses are filled
		seats_per_bus = 48

		# finds the direction with the most amount of tickets
		max_tickets = [sold_tickets(:from_waterloo), sold_tickets(:to_waterloo)].max

		# How many buses filled so far
		filled_buses = max_tickets / seats_per_bus

		# The maximum amount of seats is the current number of buses needed + whatever is needed to fill up the last bus if it is unfilled
		self.maximum_seats = filled_buses * seats_per_bus + 
			(seats_per_bus * filled_buses == tickets.count ? 0 : seats_per_bus)

		self.save
	end

	# Returns the possible return buses
	def find_returns (to_waterloo = false)

		# Array of all of the return buses
		buses = []

		# If it is a friday and the next sunday is a reading week then the return bus will be the following sunday
		# If the next sunday is not a reading week then it will be on that sunday
		if date.wday == 5
			if to_waterloo
				buses = buses + (ReadingWeek.is_reading_week?(date + 2.days) ? Bus.where(:date => (date + 9.days)) : Bus.where(:date => (date + 2.days)))
			else
				buses = buses + (ReadingWeek.is_reading_week?(date + 2.days) ? Bus.where(:date => (date + 9.days), :destination_id => destination_id) : Bus.where(:date => (date + 2.days), :destination_id => destination_id))
			end
		end

		# If there is a later bus returning on the same day then it is a valid return bus
		if to_waterloo
			buses = buses + Bus.where("date = ? AND arrive_time > ?", date, arrive_time)
		else
			buses = buses + Bus.where("date = ? AND depart_time > ? AND destination_id = ?", date, return_time, destination_id)
		end

		buses
	end
	
	# Returns the number of valid tickets for the given direction (to_waterloo or from_waterloo)
	def sold_tickets(direction)
		 (tickets.select {|t| t.direction == direction && t.status_valid? }).count
	end

	# Returns the number of available tickets for the given direction (to_waterloo or from_waterloo)
	def available_tickets(direction)
		maximum_seats ? (maximum_seats - (tickets.select {|t| t.direction == direction && t.status_valid? }).count) : nil
	end
	
	def destination_name
		"UW Campus, Waterloo (" + available_tickets(:to_waterloo).to_s + " tickets available)"
	end
	def destination_to_waterloo_name
		destination.name  + " (" + available_tickets(:from_waterloo).to_s + " tickets available)"
	end
	
	# TODO: Could shrink these name (this func and next)
	def start_time_for_bus to_waterloo
		if !to_waterloo == true
			depart_time.strftime("%I:%M %p")
		else
			arrive_time.strftime("%I:%M %p")
		end
	end
	
	def end_time_for_bus to_waterloo
		if !to_waterloo == true
			arrive_time.strftime("%I:%M %p")
		else
			self.return_time.strftime("%I:%M %p")
		end
	end
end
