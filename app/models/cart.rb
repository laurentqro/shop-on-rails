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

  # UK VAT rate (20%)
  VAT_RATE = 0.2

  # Total quantity of all items in cart
  def items_count
    cart_items.sum { |item| item.quantity }
  end

  # Sum of all cart item subtotals (before VAT)
  def subtotal_amount
    cart_items.sum { |item| item.subtotal_amount }
  end

  # Calculate VAT at 20% UK rate
  def vat_amount
    subtotal_amount * Cart::VAT_RATE
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
end
