class Invoice < ActiveRecord::Base
	STATUSES = [:unpaid, :paid]
	PAYMENT_METHODS = [:none, :visa, :mastercard, :debit, :front_desk]

	belongs_to :user
	has_and_belongs_to_many :ticket

	validates_presence_of :user_id

	symbolize :status, :in => STATUSES
	symbolize :payment, :in => PAYMENT_METHODS

	validate :paid_status_must_have_payment_specified
	validate :unpaid_status_must_have_none_as_payment

	def paid_status_must_have_payment_specified
		errors.add(:payment, "cannot be :none when status is :paid") if status == :paid and payment== :none
	end

	def unpaid_status_must_have_none_as_payment
		errors.add(:payment, "must be :none when status is :unpaid") if status == :unpaid and payment!= :none
	end
end
