class Order < ActiveRecord::Base
	validates :email, presence: true
	
	belongs_to :user, foreign_key: "buyer_id"
	belongs_to :listing, foreign_key: "listing_id"
	belongs_to :seller, foreign_key: "seller_id"
	paginates_per 8

  	def listing
    	Listing.unscoped { super }
  	end
end
