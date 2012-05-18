desc "Locks buses if their departure date comes. Run once a day."
task :lock_buses => :environment do
	buses = Bus.where("date <= ?", Date.today)
	buses.each do |b|
		b.status = :locked
		if b.save 
			puts "Locked bus #{b.id}"
		end
	end
end