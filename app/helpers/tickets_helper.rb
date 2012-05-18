module TicketsHelper
	def repeat_buses bus
		Bus.where("destination_id = ? and date >= ?", bus.destination_id, bus.date + 1.days)
	end
	
	def return_trip_for_bus buses
		if buses.length == 1
			buses[0]
		else
			(buses.inject { |d1, d2| d1.date <= d2.date ? d1 : d2 })
		end
	end
end
