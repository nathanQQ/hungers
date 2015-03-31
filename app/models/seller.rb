class Seller < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable  #, :confirmable
  validates :name, presence: true

  has_many :listings
  has_many :sales, class_name: "Order"
  acts_as_votable
end
