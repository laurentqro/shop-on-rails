class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  # POST /cart/cart_items
  # Adds a product to the current cart.
  # If the product is already in the cart, increments the quantity.
  def create
    product = Product.find_by!(slug: cart_item_params[:product_slug])
    @cart_item = @cart.cart_items.find_or_initialize_by(product: product)

    if @cart_item.new_record?
      # New item for the cart
      @cart_item.quantity = cart_item_params[:quantity].to_i || 1
      @cart_item.price = product.price # Capture current price
    else
      # Item already exists, increment quantity
      @cart_item.quantity += (cart_item_params[:quantity].to_i || 1)
    end

    if @cart_item.save
      redirect_to cart_path, notice: "#{product.name} added to cart."
    else
      # This path might be tricky to reach directly if just adding from product page.
      # Consider where to redirect or what to render if save fails.
      # For now, redirecting back or to product page with an alert.
      redirect_back fallback_location: product_path(product), alert: "Could not add item to cart: #{@cart_item.errors.full_messages.join(', ')}"
    end
  end

  # PATCH/PUT /cart/cart_items/:id
  # Updates the quantity of an item in the cart.
  def update
    new_quantity = cart_item_params[:quantity].to_i
    if new_quantity <= 0
      # If quantity is zero or less, remove the item instead
      @cart_item.destroy
      redirect_to cart_path, notice: 'Item removed from cart.'
    elsif @cart_item.update(quantity: new_quantity)
      redirect_to cart_path, notice: 'Cart updated.'
    else
      redirect_to cart_path, alert: "Could not update cart: #{@cart_item.errors.full_messages.join(', ')}"
    end
  end

  # DELETE /cart/cart_items/:id
  # Removes an item from the cart.
  def destroy
    product_name = @cart_item.product.name
    if @cart_item.destroy
      redirect_to cart_path, notice: "#{product_name} removed from cart."
    else
      # Should ideally not fail, but good to handle
      redirect_to cart_path, alert: "Could not remove item: #{@cart_item.errors.full_messages.join(', ')}"
    end
  end

  private

  # Ensures that there is a cart available for the current session/user.
  # This relies on Current.cart being set by ApplicationController or similar.
  def set_cart
    @cart = Current.cart
    unless @cart
      # This logic might be slightly different based on your ApplicationController#set_current_cart
      # If a user must always have a cart, it should be created there.
      # For guests, we might create one on demand here if not already present.
      if Current.user
        @cart = Cart.find_or_create_by(user: Current.user)
      else
        # This assumes we need to create a cart if one isn't found via session
        # which should ideally be handled by ApplicationController#set_current_cart
        # For safety, creating a new one if absolutely necessary.
        @cart = Cart.create
        session[:cart_id] = @cart.id unless session[:cart_id] # Ensure session is updated if we create it here
      end
      Current.cart = @cart # Ensure Current object is updated if we had to create it here
    end
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def cart_item_params
    params.expect(cart_item: [ :product_slug, :quantity ])
  end
end