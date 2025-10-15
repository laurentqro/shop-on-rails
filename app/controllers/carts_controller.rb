class CartsController < ApplicationController
  allow_unauthenticated_access
  before_action :eager_load_cart, only: :show

  def show
  end

  def destroy
    @cart.destroy
    redirect_to root_path, notice: "Cart was successfully destroyed."
  end

  private

  def eager_load_cart
    # Eager load cart items with their associations to prevent N+1 queries
    Current.cart.cart_items.includes(product_variant: { product: :image_attachment }).load if Current.cart
  end

  def cart_params
    params.expect(cart: [ :user_id ])
  end
end
