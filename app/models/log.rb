class Log < ActiveRecord::Base
	# model is the model type of log (Ticket, User, Bus, Trip, etc.)
	# source_id is the id of the model

	validates_presence_of :message, :model, :source_id

	# Creates and returns a log
	def self.make_log message, model, source, user = nil
		l = Log.new
		l.message = message
		l.model = model.classify
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
		model.constantize.find(source_id)
	end

end