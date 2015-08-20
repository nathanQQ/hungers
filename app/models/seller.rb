class Seller < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  validates :name, :email, :address_line1, :city, :state, :zip_code, :tax_rate, :phone,:weekday_open_at, :weekday_close_at, :saturday_open_at, :saturday_close_at, :sunday_open_at, :sunday_close_at, presence: true

  has_many :listings
  has_many :sales, class_name: "Order"
  acts_as_votable
end
