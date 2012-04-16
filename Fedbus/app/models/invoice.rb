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

		i.save
		i
	end
	
	def update_invoice tickets
		self.tickets = tickets
		self.total = tickets.inject(0) { |result, t| result + t.ticket_price }
		self.updated_at = Time.now
		self.save

		self
	end

	# Locks the invoice
	def lock

	end
end
