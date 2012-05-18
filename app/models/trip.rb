class Trip < ActiveRecord::Base
	has_many :buses
	belongs_to :destination

	validates_presence_of :name, :destination, :weekday, :depart_time, :arrive_time, :return_time, :ticket_price, :sales_lead
end
