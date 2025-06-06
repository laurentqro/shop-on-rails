class Cart < ApplicationRecord
  belongs_to :user, optional: true

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  VAT_RATE = 0.2

  def items_count
    cart_items.sum { |item| item.quantity }
  end

  def subtotal_amount
    cart_items.sum { |item| item.subtotal_amount }
  end

  def vat_amount
    subtotal_amount * Cart::VAT_RATE
  end

  def total_amount
    subtotal_amount + vat_amount
  end

  def guest_cart?
    user.blank?
  end
end
