desc "Creates buses for all trips within the sales lead time. Run once a day."
task :create_buses => :environment do
	# These get today's date and all of the trips
	currentDay = Date.today
	trips = Trip.all
	
	# For each trip, buses are created for each day in the sales lead
	trips.each do |t|
		for i in (0..t.sales_lead)
			# Is the current day a holiday?
			holiday = Holiday.is_holiday?(currentDay + i)
		
			# If today + i is the correct day of the week and if there are no buses for this day then a new bus is created
			if (currentDay + i).wday == t.weekday && !Blackout.is_blackout?(currentDay + i) && !ReadingWeek.is_reading_week?(currentDay + i) && Bus.where("date = ? AND trip_id = ?", (holiday ? holiday.offset_date : currentDay + i), t.id).empty?

					bus = Bus.new
					bus.accessible = :all
					bus.create_bus_from_trip(t, (holiday ? holiday.offset_date : currentDay + i))

					if bus.save
						puts "Creating bus for trip: " + t.name + " on " + (holiday ? holiday.offset_date : currentDay + i).strftime("%A %B %d %Y")
					end

			end
		end
	end
end