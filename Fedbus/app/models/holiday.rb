class Holiday < ActiveRecord::Base

	# Checks if the given date is a holiday and if so returns the holiday
	def self.is_holiday? given_date
		holidays = Holiday.where("date = ?", given_date)
		if !holidays.empty?
			holidays.first
		else
			false
		end
	end

end
