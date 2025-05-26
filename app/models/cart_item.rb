class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  VAT_RATE = 0.2

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :product, scope: :cart

  def total_amount
    subtotal_amount + vat_amount
  end

  def vat_amount
    subtotal_amount * VAT_RATE
  end

  def subtotal_amount
    price * quantity
  end
end
