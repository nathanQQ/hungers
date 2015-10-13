class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # add filter to only allow user to create order
  before_action :check_user, except: [:sales, :confirm_pickup]

  def purchases
    @orders = Order.all.where(user: current_user).order("created_at DESC").page(params[:page])
  end

  def sales
    if !(@sales_month = params[:month])
      #show sales history today/tomorrow
      @orders = Order.all.where(:seller => current_seller, :pickup_time => (Date.today.at_beginning_of_day)..Date.tomorrow.at_end_of_day).order("pickup_time ASC").page(params[:page])
      @month_to_time = Date::MONTHNAMES[Date.today.month].to_time  
    else
      #show sales history by month.
      #Note: if the pickup date of a listing is the first date of a month, all the orders made in pior month will be treated as the orders in current month.
      #It means: orders made on the last date(last 3 hours specifically) of each month will be counted in the next month
      @sales_month = @sales_month.to_i
      @month_to_time = Date::MONTHNAMES[@sales_month].to_time  
      @orders = Order.all.where(:seller => current_seller, :pickup_time => (@month_to_time.at_beginning_of_month)..@month_to_time.at_end_of_month).order("created_at ASC")
    end
      @sale_tax = 0
      @total_sale = 0
      @total_collected = 0
      @orders.each do |order|
        @sale_tax = @sale_tax + order.tax
        @total_sale = @total_sale + order.nr_order * order.listing.price
        @total_collected = @total_collected + order.collected    
      end
  end

  def confirm_pickup
    @order = Order.find(params[:id])
    @order.is_pickedup ^= true
    @order.save
    redirect_to sales_path
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
    if @listing.sold_date != 3.hours.from_now.to_date
      redirect_to listings_path, notice: "Sorry,this listing is not for sale today!"
    end
    if @listing.seller.tax_rate.blank?
      redirect_to listings_path, notice: "Sorry, the seller hasn't updated sales tax info."      
    end
    if params[:is_new_cc]
      current_user.stripe_customer_id = nil
    end

    if !(@nr_order = params[:quantity])
      @nr_order = 1
    else
      @nr_order = @nr_order.to_i
    end
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

    @nr_order = @order.nr_order
    if !@nr_order
      @nr_order = 1
    else
      @nr_order = @nr_order.to_i
    end

    #all the variables are in the unit of cent, and round up to 1 cent
    @pre_tax = @listing.price * @nr_order * 100
    @tax = (@pre_tax * @listing.seller.tax_rate * 0.01).ceil
    @total_price =  (@pre_tax + @tax).ceil #ceil is to make stripe happy.
    @transaction_fee = (@total_price * 0.029 + 45).ceil
    @transfer_to_seller = (@total_price - @transaction_fee).floor #floor is also to make stripe happy.

    @order.transaction_fee = @transaction_fee
    @order.collected = @transfer_to_seller

    Stripe.api_key = ENV["STRIPE_API_KEY"]
    token = params[:stripeToken] 
    respond_to do |format|
      if @order.save
        begin          
          order_id = SecureRandom.hex(2).upcase + '-' + SecureRandom.hex(2).upcase
          if @listing.seller.address_line2.blank?
            seller_address = @listing.seller.address_line1 + ', ' + @listing.seller.city + ', ' + @listing.seller.state + ', ' + @listing.seller.zip_code
          else
            seller_address = @listing.seller.address_line1 + ', ' + @listing.seller.address_line2 + ', ' + @listing.seller.city + ', ' + @listing.seller.state + ', ' + @listing.seller.zip_code
          end
          seller_email = @listing.seller.email
          purchased_item = @listing.name
          purchased_amount = @nr_order
          pickup_time = @order.pickup_time
          seller = Seller.find(@order.seller_id)
          seller_name = seller.name

          
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
              :amount => @total_price,
              :currency => "usd",
              :customer => customer.id,
              :metadata => {
                :email => current_user.email,                 
                :order_id => order_id,
                :seller_name => seller_name,
                :seller_address => seller_address,
                :seller_email => seller_email,
                :purchased_item => purchased_item,
                :purchased_amount => purchased_amount,
                :total_price => @total_price/100.0,
                :pickup_time => pickup_time.strftime("%H:%M, %B %-d, %Y")}
              )
            else  #does_remember_card
              charge = Stripe::Charge.create(
              :amount => @total_price,
              :currency => "usd",
              :card => token,
              :metadata => {
                :email => current_user.email, 
                :order_id => order_id,
                :seller_name => seller_name,
                :seller_address => seller_address,
                :seller_email => seller_email,
                :purchased_item => purchased_item,
                :purchased_amount => purchased_amount,
                :total_price => @total_price/100.0,
                :pickup_time => pickup_time.strftime("%H:%M, %B %-d, %Y")}              
              ) 
            end   #does_remember_card      

          else  #token 
            customer_id = current_user.stripe_customer_id
            charge = Stripe::Charge.create(
            :amount => @total_price,
            :currency => "usd",
            :customer => customer_id,
            :metadata => {
              :email => current_user.email, 
              :order_id => order_id,
              :seller_name => seller_name,
              :seller_address => seller_address,
              :seller_email => seller_email,
              :purchased_item => purchased_item,
              :purchased_amount => purchased_amount,
              :total_price => @total_price/100.0,
              :pickup_time => pickup_time.strftime("%H:%M, %B %-d, %Y")}
            )            
          end  #token
          
          # create transfer.
          transfer = Stripe::Transfer.create(
            :amount => @transfer_to_seller,
            :currency => "usd",
            :recipient => @listing.seller.recipient
            ) 

          flash[:notice] = "Thanks for ordering!"
          rescue Stripe::CardError => e
          flash[:danger] = e.message
        end #begin 
        
        @order.update_attribute(:order_id, order_id)
        @order.update_attribute(:tax, @tax)
        @listing.nr_order += @nr_order
        @listing.save
        format.html { redirect_to listings_path, notice: "Your order was successfully created!\nYou will receive the order number via email. Please use it for your pick up:)" }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:pickup_time, :nr_order)
    end
    
    def check_user
      if seller_signed_in?
        redirect_to listings_path, notice: "Seller, please sign out first! Placing an order with your buyer account!"
      elsif admin_signed_in?
        redirect_to listings_path, notice: "Admin, please sign out first! Placing an order with your buyer account!"
      elsif !user_signed_in?
        redirect_to user_session_url, notice: "please sign in to continue"
      end
    end    
end
