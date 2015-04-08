class ReceiptMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def send_receipt charge
    @charge = charge
    @amount = charge.amount.to_i/100
    @id = charge.id.upcase
    mail(:to => charge.metadata.email, :subject => "Your order id is #{@id}")
  end
end