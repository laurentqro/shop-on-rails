class ApplicationController < ActionController::Base
  before_action :set_current_cart
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def set_current_cart
    if Current.user
      # User is logged in
      # Find their existing cart or create a new one if it doesn\'t exist
      Current.cart = Cart.find_or_create_by(user: Current.user)
    elsif session[:cart_id]
      # Guest user with a cart_id in session
      # Attempt to find the cart
      cart = Cart.find_by(id: session[:cart_id])
      if cart&.user_id.nil? # Ensure it\'s a guest cart (no user_id)
        Current.cart = cart
      else
        # Cart ID in session is invalid (e.g., belongs to a user or doesn\'t exist, or was claimed)
        # Clear the session and create a new guest cart
        session.delete(:cart_id)
        Current.cart = Cart.create # Create a new cart without a user
        session[:cart_id] = Current.cart.id if Current.cart.persisted?
      end
    else
      # Guest user with no cart_id in session (new guest)
      # Create a new guest cart
      Current.cart = Cart.create # Create a new cart without a user
      session[:cart_id] = Current.cart.id if Current.cart.persisted?
    end
  end
end
