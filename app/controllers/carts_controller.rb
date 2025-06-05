class CartsController < ApplicationController
  allow_unauthenticated_access

  def show
  end

  def destroy
    @cart.destroy
    redirect_to root_path, notice: "Cart was successfully destroyed."
  end

  private

  def cart_params
    params.expect(cart: [ :user_id ])
  end
end
