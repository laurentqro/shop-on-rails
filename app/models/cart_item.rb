class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  has_one :product, through: :product_variant

  VAT_RATE = 0.2

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :product_variant, scope: :cart

  before_validation :set_price_from_variant

  def subtotal_amount
    price * quantity
  end

  private

  def set_price_from_variant
    self.price = product_variant.price if product_variant && price.blank?
  end
end
