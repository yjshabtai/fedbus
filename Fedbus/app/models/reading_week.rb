class ReadingWeek < ActiveRecord::Base
	
	def self.is_reading_week? given_date
		!ReadingWeek.where("start_date <= ? and end_date >= ?", given_date, given_date).empty?
	end
	
end
