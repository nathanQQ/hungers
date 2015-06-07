class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  # define filters: 
  # 1. only seller can add/delete/modify listing - devise's filter
  # 2. only listing's seller can modify the listing - need to define the filter
  before_action :authenticate!, only: [:new, :create, :destroy, :edit, :update, :my_listings]
  before_action :check_seller, only: [:edit, :update, :destroy]
  # only user can like a listing
  before_action :check_user, only:[:like, :bookmark]
  

  #remember one restaurant
  def bookmark
    @listing = Listing.find(params[:id])
    if current_user.liked? @listing.seller
      current_user.dislikes @listing.seller
      redirect_to listing_path, notice: "change my taste. Will not follow this restaurant!"
    else
      current_user.likes @listing.seller
      redirect_to listing_path, notice: "restaurant bookmarked! You can go to Manage to check your favorite food from your bookmarked restaurants!"
    end 
  end

  #used for voting a menu
  def like
    @listing = Listing.find(params[:id])
    if current_user.liked? @listing
      redirect_to listing_path, notice: "already liked by you!"
    else
      @listing.liked_by current_user
      redirect_to listing_path, notice: "Thanks for liking me!"
    end
  end

  #select the listings from favorate sellers
  def show_bookmark 
    @listings = []
    @sellers = Seller.order(:cached_votes_up => :desc)
    @sellers.each do |seller|
      if current_user.liked? seller
        @listings_tmp = seller.listings.where(:sold_date => 3.hours.from_now.to_date).order(:cached_votes_up => :desc)
        @listings_tmp.each do |listing|
          @listings.append(listing)
        end
      end
    end
    @listings = Kaminari.paginate_array(@listings).page(params[:page]).per(8)
  end

  #sort by most liked
  def sort 
    @listings = Listing.where(:sold_date => 3.hours.from_now.to_date).order(:cached_votes_up => :desc).page(params[:page])
  end

  def index_weighted
    @listings = []
    @sellers = Seller.order(:is_promoted => :desc)
    @sellers.each do |seller|
      #@listings_tmp = seller.listings.where(:sold_date => 3.hours.from_now.to_date).order(:cached_votes_up => :desc)
      @listings_tmp = seller.listings.where(:sold_date => 3.hours.from_now.to_date).order(:updated_at => :asc)
      @listings_tmp.each do |listing|
        @listings.append(listing)
      end
    end
    @listings = Kaminari.paginate_array(@listings).page(params[:page]).per(8)
  end

  # GET /listings
  # GET /listings.json
  def index
    #if params[:page]
    #  session[:listing_idex_page] = params[:page]
    #end
    #@listings = Listing.order("created_at DESC").page(session[:listing_index_page])
    @listings = Listing.where(:sold_date => 3.hours.from_now.to_date).order("created_at DESC").page(params[:page])
    # ordered by most liked
    #@listings = Listing.order(:cached_votes_up => :desc).page(params[:page])
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
    @listing = Listing.find(params[:id])
  end

  def my_listings
    #@listings = Listing.where(:seller => current_seller).where("#{:sold_date} >= ?", Date.today).order("sold_date ASC").page(params[:page])
    @listings = Listing.where(:seller => current_seller).order("sold_date DESC").page(params[:page])
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)
    @listing.seller_id = current_seller.id
    
    if current_seller.recipient.blank?
      Stripe.api_key = ENV["STRIPE_API_KEY"]
      token = params[:stripeToken] 
      
      recipient = Stripe::Recipient.create(
      :name => current_seller.name,
      :type => "individual", #WQ TODO
      :bank_account => token
      )  
      
      current_seller.recipient = recipient.id
      current_seller.save
    end

    respond_to do |format|
      if @listing.save   
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:name, :description, :price, :image, :sold_date, :country, :routing_number, :account_number)
    end

    def authenticate!
      if admin_signed_in?
        true
      else
        authenticate_seller!
      end
    end

    def check_seller
      if admin_signed_in?
        true
      elsif
        current_seller != @listing.seller
        redirect_to root_url, notice: "Cannot modify the listing belongs to others!"
      end
    end
    
    def check_user
      if seller_signed_in?
        redirect_to root_url, notice: "Seller is not allowed to like any listing!"
      elsif admin_signed_in?
        redirect_to root_url, notice: "Admin is not allowed to like any listing!"
      elsif !user_signed_in?
        redirect_to user_session_url, notice: "please sign in to continue"
      end
    end    
end
