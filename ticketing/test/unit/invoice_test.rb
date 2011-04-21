require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
	test "fixtures should be valid" do
		assert invoices(:one).valid?, "First invoice not valid"
		assert invoices(:two).valid?, "Second invoice not valid"
	end

	test "invoice should not accept an invalid status" do
		assert assign_invalid_value(invoices(:one), :status, :foogle),
			"Should not accept :foogle as a status"
	end

	test "invoice should not accept an invalid payment" do
		assert assign_invalid_value(invoices(:one), :payment, :foogle),
			"Should not accept :foogle as a payment"
	end

	test "should not create invoice without user" do
		i = invoices(:one)
		i.user = nil
		assert i.invalid?, "Invoice should not be valid without user"
	end

	test "should not allow paid invoice to have none as payment method" do
		i = invoices(:one)
		i.status = :paid
		assert i.invalid?, "Invoice should not have none as payment method when status is paid"
	end

	test "should not allow unpaid invoice to have payment method other than none" do
		i = invoices(:two)
		i.payment = :none
		assert i.invalid?, "Invoice cannot be paid when payment is none"
	end
end
