class NotifyMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"] #WQ TODO

  def notify_seller charge
    @customer = charge.metadata.email
    @order_id = charge.metadata.order_id
    @seller = charge.metadata.seller_email
    mail(:to => @seller, :subject => "Your new order from Hungers.me")
  end
end