class ReceiptMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def send_receipt charge
    @charge = charge
    @amount = charge.amount.to_i/100
    #@id = charge.id.upcase
    @id = (0...8).map { (65 + rand(26)).chr }.join
    mail(:to => charge.metadata.email, :subject => "Your Hungers.me order")
  end
end