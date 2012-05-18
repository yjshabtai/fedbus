class Invoice < ActiveRecord::Base
	# Unpaid is default. Paid occurs when the invoice is paid. Locked is when the invoice is discarded.
	STATUSES = [:unpaid, :paid, :locked]
	
	# TODO: Make this a HABTM
	has_many :tickets
	belongs_to :user
	
	validates_presence_of :user_id

	def self.make_invoice tickets
		i = Invoice.new
		i.tickets = tickets
		i.status = :unpaid
		i.payment = :none
		i.user_id = tickets[0].user_id
		i.total = tickets.inject(0) { |result, t| result + t.ticket_price }

		if i.save
			Log.make_log "Invoice #{i.id.to_s} has been created", "Invoice", i.id
		end
		i
	end
	
	def update_invoice tickets
		self.tickets = tickets
		self.total = tickets.inject(0) { |result, t| result + t.ticket_price }
		self.updated_at = Time.now
		
		if self.save
			Log.make_log "Invoice #{self.id.to_s} has been updated", "Invoice", self.id
		end

		self
	end

	# Locks the invoice
	def lock
		self.status = :locked
		
		if self.save
			Log.make_log "Invoice #{self.id.to_s} has been locked", "Invoice", self.id
		end
	end
end
