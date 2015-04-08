class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # add filter to only allow user to create order
  before_action :check_user, except: [:sales]

  def purchases
    @orders = Order.all.where(user: current_user).order("created_at DESC")
  end

  def sales
    @orders = Order.all.where(seller: current_seller).order("created_at DESC").page(params[:page])
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])

    @order.buyer_id = current_user.id
    @order.seller_id = @listing.seller.id
    @order.listing_id = @listing.id
    @order.email = current_user.email

    Stripe.api_key = ENV["STRIPE_API_KEY"]
    token = params[:stripeToken] 
    respond_to do |format|
      if @order.save
        begin          
          #there is credit card token created by js due to new customer
          if token
            does_remember_card = params[:rmcc]
            if does_remember_card == 'true'
              customer = Stripe::Customer.create(
                :card => token,
                :description => 'credit card description',
                :email => current_user.email
                )

              current_user.update_attribute(:stripe_customer_id, customer.id)

              charge = Stripe::Charge.create(
              :amount => (@listing.price * 100).floor,
              :currency => "usd",
              :customer => customer.id,
              :metadata => {
                #WQ TODO
                #:email => current_user.email 
                :email => "wuwq85@gmail.com"}
              ) 
            else  #does_remember_card
              charge = Stripe::Charge.create(
              :amount => (@listing.price * 100).floor,
              :currency => "usd",
              :card => token,
              :metadata => {
                #WQ TODO
                #:email => current_user.email 
                :email => "wuwq85@gmail.com"}
              ) 
            end   #does_remember_card      

          else  #token 
            customer_id = current_user.stripe_customer_id
            charge = Stripe::Charge.create(
            :amount => (@listing.price * 100).floor,
            :currency => "usd",
            :customer => customer_id,
            :metadata => {
              #WQ TODO
              #:email => current_user.email 
              :email => "wuwq85@gmail.com"}
            )            
          end  #token
          flash[:notice] = "Thanks for ordering!"
          rescue Stripe::CardError => e
          flash[:danger] = e.message
        end        
        format.html { redirect_to root_url, notice: "Order was successfully created. We will send receipt to your email. Use it for pick up." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through. WQ TODO
    def order_params
      #params.require(:order).permit()
    end
    
    def check_user
      if seller_signed_in?
        redirect_to root_url, notice: "Seller, please sign out first! Placing an order with your buyer account!"
      elsif admin_signed_in?
        redirect_to root_url, notice: "Admin, please sign out first! Placing an order with your buyer account!"
      elsif !user_signed_in?
        redirect_to root_url, notice: "Please sign in first before making an order!"
      end
    end    
end
