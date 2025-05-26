class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def items_count
    cart_items.sum { |item| item.quantity }
  end

  def subtotal_amount
    cart_items.sum { |item| item.subtotal_amount }
  end

  def total_amount
    cart_items.sum { |item| item.total_amount }
  end
end
