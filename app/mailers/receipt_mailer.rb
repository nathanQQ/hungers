class ReceiptMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def send_receipt charge
    @charge = charge
    @amount = charge.amount.to_i/100
    mail(
      :to => charge.metadata.email,
      :subject => "Your Receipt Number from Hungers.me: #{charge.id}"
    )
  end
end