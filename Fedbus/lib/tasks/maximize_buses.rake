desc "Sets the maximum amount of seats for buses. Run every Wednesday morning."
task :maximize_buses => :environment do
	# This gets all of the buses in the following week
	buses = Bus.where("date >= ? and date <= ?", Date.today, Date.today + 1.weeks)

	# Each bus in 'buses' has its seats maximized
	buses.each do |b|
		b.maximize_seats

		puts "Maximizing the number of seats for bus #{b.id}."
	end
end