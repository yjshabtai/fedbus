class Ticket < ActiveRecord::Base
  DIRECTIONS = [:from_waterloo, :to_waterloo]
	STATUSES = [:reserved, :paid, :void, :expired, :used]
	
	belongs_to :bus
	belongs_to :user
	belongs_to :invoice

	belongs_to :return_of, :class_name => "Ticket", :foreign_key => "return_of"
	has_one :return_ticket, :class_name => "Ticket", :foreign_key => "return_of"
	
	has_many :ticket_logs
	
	validates_presence_of :user_id, :bus_id, :direction, :status
	
	# Creates the ticket and sets it as paid if being sold or reserved if being purchased
	def self.make_ticket user, bus, direction, seller = nil
		t = Ticket.new
		t.bus = bus
		t.user = user
		t.status = seller ? :paid : :reserved
		t.direction = direction
		t.ticket_price = bus.ticket_price
		
		if t.save
			TicketLog.make_log (seller ? ("Ticket sold by vendor") : "Ticket reserved by system"), t, seller
			Log.make_log (seller ? ("Ticket sold") : "Ticket reserved"), "Ticket", t.id, (seller ? seller.id : 0)

			t
		else
			TicketLog.make_log (seller ? ("Ticket sale failed by vendor") : "Ticket reservation failed by system"), t, seller
			
			false
		end
	end
	
	# valid = true returns tickets whose status is either paid or reserved
	# valid = false returns tickets whose status is either void or expired
	def status_valid? valid = true
		if valid   
			Ticket::STATUSES[0..1].include? status.to_sym
		else
			Ticket::STATUSES[2..4].include? status.to_sym
		end
	end

	def description
		(direction == 'from_waterloo' ? ("UW Campus to " + bus.destination.name) : (bus.destination.name + " to UW Campus")) + " on " + bus.date.strftime("%B %e, %Y")
	end
end