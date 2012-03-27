class Invoice < ActiveRecord::Base
	STATUSES = [:unpaid, :paid]
	
	# TODO: Make this a HABTM
	has_many :tickets
	belongs_to :user
	
	validates_presence_of :user_id
	
	def objs_type
		"invoices"
	end

	def self.make_invoice tickets
		i = Invoice.new
		i.tickets = tickets
		i.status = :unpaid
		i.payment = :none
		i.user_id = tickets[0].user_id
		i.total = tickets.inject(0) { |result, t| result + t.ticket_price }

		i.save
		return i
	end
	
	def update_invoice tickets
		self.tickets = tickets
		self.user_id = tickets[0].user_id
		self.total = tickets.inject(0) { |result, t| result + t.ticket_price }
		self.save
	end
end
