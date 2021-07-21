class Public::OrdersController < ApplicationController
  def new
    @order = Order.new
    @customer = current_customer
    @delivery = Delivery.new
  end

  def confirm
    @order= Order.new(order_params)
    @order_detail = OrderDetail.new
    @customer = current_customer
    @cart_items = CartItem.where(customer_id: @customer.id).all


    @order.customer_id=@customer.id
    @order.shipping = 800

    if @order.address_kind==1
      @order.address = @customer.address
      @order.postcode = @customer.postal_code
      @order.name = 'aaa'

    elsif @order.address_kind == 2
      @delivery = Delivery.find_by(id: params[:order][:deliveryid])

      @order.address = @delivery.address
      @order.postcode = @delivery.postcode
      @order.name = @delivery.name

    elsif @order.address_kind == 3
      @newdelivery = Delivery.new
      @newdelivery.customer_id = @customer.id
      @newdelivery.postcode = @order.postcode
      @newdelivery.address = @order.address
      @newdelivery.name = @order.name
    end



    @order.status = 0
    render :new if @order.address_kind==nil


  end

  def create
    @order= Order.new(order_params)

    @customer = current_customer

    @cart_items = CartItem.where(customer_id: @customer.id)

    @order.customer_id=@customer.id
    @order.shipping = 800
    @customer = current_customer
    @order.status = 0
    @order.total_payment = 100

    if @order.save
      @cart_items.each{|cart_item|
        @order_detail = OrderDetail.new
        @order_detail.order_id = @order.id
        @order_detail.product_id = cart_item.product_id
        @order_detail.quantity = cart_item.quantity
        @order_detail.price = cart_item.product.add_tax_price.to_s(:price)
        @order_detail.production_status = 0
        @order_detail.save

      }

      redirect_to '/orders'

    else
      render :confirm
    end
  end


  def index
    @orders = Order.order(id: :DESC)
    @order_details = OrderDetail.all
  end

  def show
  end


  def order_params
    params.require(:order).permit(:customer_id, :name, :postcode, :address, :shipping, :payment_methods, :total_payment, :status,:address_kind)
  end
  def delivery_params
    params.require(:delivery).permit(:name, :postcode, :address)
  end
end