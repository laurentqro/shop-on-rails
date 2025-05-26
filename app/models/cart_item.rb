class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  VAT_RATE = 0.2

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :product, scope: :cart

  def subtotal_amount
    price * quantity
  end
end
