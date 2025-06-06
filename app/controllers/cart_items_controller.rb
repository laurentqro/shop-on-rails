class CartItemsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_cart
  before_action :set_cart_item, only: [ :update, :destroy ]

  # POST /cart/cart_items
  def create
    product_variant = ProductVariant.find_by!(sku: cart_item_params[:variant_sku])
    @cart_item = @cart.cart_items.find_or_initialize_by(product_variant: product_variant)

    if @cart_item.new_record?
      @cart_item.quantity = cart_item_params[:quantity].to_i || 1
      @cart_item.price = product_variant.price
    else
      @cart_item.quantity += (cart_item_params[:quantity].to_i || 1)
    end

    if @cart_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path, notice: "#{product_variant.display_name} added to cart." }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: product_path(product_variant.product), alert: "Could not add item to cart: #{@cart_item.errors.full_messages.join(', ')}" }
      end
    end
  end

  # PATCH/PUT /cart/cart_items/:id
  def update
    new_quantity = cart_item_params[:quantity].to_i
    if new_quantity <= 0
      # If quantity is zero or less, remove the item instead
      @cart_item.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path, notice: "Item removed from cart." }
      end
    elsif @cart_item.update(quantity: new_quantity)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path, notice: "Cart updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("basket_counter", partial: "shared/basket_counter") }
        format.html { redirect_to cart_path, alert: "Could not update cart: #{@cart_item.errors.full_messages.join(', ')}" }
      end
    end
  end

  # DELETE /cart/cart_items/:id
  def destroy
    product_name = @cart_item.product_variant.display_name
    @cart_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: "#{product_name} removed from cart.", status: :see_other }
    end
  end

  private

  # Ensures that there is a cart available for the current session/user.
  # This relies on Current.cart being set by ApplicationController or similar.
  def set_cart
    @cart = Current.cart

    unless @cart
      set_current_cart
      @cart = Current.cart
    end
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def cart_item_params
    params.expect(cart_item: [ :variant_sku, :quantity ])
  end
end
