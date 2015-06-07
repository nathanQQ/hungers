#class ManagementController < ActionController::Base
class ManagementController < ApplicationController
  before_action :authenticate_admin!

  
  def show_listings
    @listings = Listing.order("seller_id ASC").page(params[:page])
  end

  def show_listings_today
    @listings = Listing.where(:sold_date => Date.today).order("seller_id ASC").page(params[:page])
  end

  def show_sellers
    @sellers = Seller.order('created_at ASC')
  end

  def promote
  	@seller = Seller.find(params[:id])
  	if @seller.is_promoted == false
		@seller.update_attribute(:is_promoted, true)
  		redirect_to management_show_sellers_path, notice: "promoted #{@seller.name}"		
  	else 
  		@seller.update_attribute(:is_promoted, false)
  		redirect_to management_show_sellers_path, notice: "delete promotion on #{@seller.name}"
  	end
  end

end