class ReceiptMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def send_receipt charge
    @charge = charge
    @amount = charge.amount.to_i/100
    @customer = charge.metadata.email
    @order_id = charge.metadata.order_id
    @address = charge.metadata.seller_address
    @seller = charge.metadata.seller_email
    mail(:to => @customer, :subject => "Your Hungers.me order")
  end
end