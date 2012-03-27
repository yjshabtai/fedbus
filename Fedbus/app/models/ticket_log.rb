class TicketLog < ActiveRecord::Base
	belongs_to :user
	belongs_to :ticket
	
	validates_presence_of :log, :ticket_id
	
	def objs_type
		"ticket_logs"
	end
	
	def self.make_log log_message, ticket, user = nil
		l = TicketLog.new
		l.log = log_message
		l.ticket = ticket
		l.user = user

		# TODO: What if this fails?
		l.save

		return l
	end
end
