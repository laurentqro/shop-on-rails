class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def items_count
    cart_items.sum { |item| item.quantity }
  end

  def subtotal
    cart_items.sum { |item| item.price * item.quantity }
  end

  def total_price
    cart_items.sum { |item| item.price * item.quantity }
  end
end
