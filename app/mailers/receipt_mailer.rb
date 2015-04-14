class ReceiptMailer < ActionMailer::Base
  default :from  => ENV["EMAIL_USER"]

  def send_receipt charge
    @charge = charge
    @amount = charge.amount.to_i/100
    #@id = (0...8).map { (65 + rand(26)).chr }.join
    @id = SecureRandom.hex(2).upcase + '-' + SecureRandom.hex(2).upcase
    mail(:to => charge.metadata.email, :subject => "Your Hungers.me order")
  end
end