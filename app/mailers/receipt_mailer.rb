class ReceiptMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def send_receipt charge
    @charge = charge
    @amount = charge.amount.to_i/100
    @customer = charge.metadata.email
    @order_id = charge.metadata.order_id
    @address = charge.metadata.seller_address
    @seller_name = charge.metadata.seller_name
    @seller_email = charge.metadata.seller_email
    @purchased_item = charge.metadata.purchased_item
    @purchased_amount = charge.metadata.purchased_amount
    @total_price = charge.metadata.total_price
    @pickup_time = charge.metadata.pickup_time   
    mail(:to => @customer, :subject => "Your Hungers.me order")
  end
end