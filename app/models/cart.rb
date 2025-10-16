# Shopping cart for storing items before checkout
#
# Supports both guest and authenticated user carts:
# - Guest carts: user_id is nil, tracked by cookie session
# - User carts: associated with a User record
#
# On login, guest cart items are merged into the user's cart
#
# VAT calculation:
# - UK VAT rate of 20% (VAT_RATE = 0.2)
# - VAT calculated on subtotal (sum of all cart items)
# - Final total = subtotal + VAT
#
# Usage:
#   Current.cart              # Access current cart (guest or user)
#   cart.items_count          # Total quantity of all items
#   cart.subtotal_amount      # Sum before VAT
#   cart.vat_amount           # 20% VAT on subtotal
#   cart.total_amount         # Final total with VAT
#
class Cart < ApplicationRecord
  belongs_to :user, optional: true

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Total quantity of all items in cart
  # Uses database aggregation to avoid N+1 queries
  # Memoized to prevent repeated database calls within same request
  def items_count
    @items_count ||= cart_items.sum(:quantity)
  end

  # Sum of all cart item subtotals (before VAT)
  # Uses database calculation: SUM(price * quantity)
  # Memoized to prevent repeated database calls within same request
  def subtotal_amount
    @subtotal_amount ||= cart_items.sum("price * quantity")
  end

  # Calculate VAT at UK rate (20%)
  # Uses global VAT_RATE constant from config/initializers/vat.rb
  def vat_amount
    subtotal_amount * VAT_RATE
  end

  # Final total including VAT
  # Note: Shipping cost is added separately at checkout via Stripe
  def total_amount
    subtotal_amount + vat_amount
  end

  # Check if this is a guest cart (not associated with a user)
  def guest_cart?
    user.blank?
  end

  # Clear memoized values when cart items change
  # Call this after adding/updating/removing cart items
  def reload(*)
    @items_count = nil
    @subtotal_amount = nil
    super
  end
end
