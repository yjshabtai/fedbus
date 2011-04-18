class Invoice < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :ticket

	validates_presence_of :user_id
end
