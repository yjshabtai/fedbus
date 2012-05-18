class Blackout < ActiveRecord::Base

	def self.is_blackout? given_date
		!Blackout.where("start <= ? and expiry >= ?", given_date, given_date).empty?
	end
	
end
