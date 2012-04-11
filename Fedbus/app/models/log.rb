class Log < ActiveRecord::Base
	# type is the model type of log (Ticket, User, Bus, Trip, etc.)
	# source_id is the id of the type

	validates_presence_of :message, :type, :source_id

	# Creates and returns a log
	def self.make_log message, type, source, user = nil
		l = Log.new
		l.message = message
		l.type = type.classify
		l.source_id = source
		l.user_id = user ? user : 0

		if l.save
			l
		else
			nil
		end
	end

	# Finds the object that the log was created for
	def source
		type.constantize.find(source_id)
	end

end