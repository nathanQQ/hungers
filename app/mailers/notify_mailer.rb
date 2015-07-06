class NotifyMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def notify_seller charge
    @customer = charge.metadata.email
    @order_id = charge.metadata.order_id
    @seller_email = charge.metadata.seller_email
    mail(:to => @seller_email, :subject => "Your new order from Hungers.me")
  end
end