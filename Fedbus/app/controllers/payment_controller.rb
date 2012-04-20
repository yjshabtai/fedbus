require 'keys.rb'

class PaymentController < ApplicationController
  def cart
  	@curr_user = current_user

    @curr_user.set_prices
    @tickets = @curr_user.reserved_tickets
    @price = 0.00

    @tickets.each do |tick|
      @price = @price + tick.ticket_price
    end

    
  end

  def payinfo
  	@curr_user = current_user

    @curr_user.set_prices
    @tickets = @curr_user.reserved_tickets
    @price = 0.00

    @tickets.each do |tick|
      @price = @price + tick.ticket_price
    end
    
    # If an invoice is not created then one must be created
    # If one is created then it is updated
    invoice_id = session[:invoice]
    if !invoice_id
      @invoice = Invoice.make_invoice @tickets
      session[:invoice] = @invoice.id
    else
      @invoice = Invoice.find(invoice_id).update_invoice @tickets
      session[:invoice] = @invoice.id
    end

    @amount = (@price * 100).to_i.to_s
    @timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    @merchant_id = Keys.merchant_id
    @hash = Digest::SHA1.hexdigest(@invoice.id.to_s + '|' + @amount + '|' + @timestamp + '|' + Keys.admeris_hash)

  	@resp_url = 'http://' + request.env['HTTP_HOST'] + '/response'
  end

  def admeris_response
  end
end
