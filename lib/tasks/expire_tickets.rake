desc "Expires reserved tickets if older than 15 minutes"
task :expire_tickets => :environment do
	expireTime = Time.now - 15.minutes
	tickets = Ticket.where("created_at <= ? and status = ?", expireTime, :reserved)
	
	tickets.each do |t|
		t.status = :expired
		t.save!
		
		TicketLog.make_log "Expired by default", t
		puts "Expired ticket #" + t.id.to_s
	end
end