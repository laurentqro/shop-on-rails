class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  has_one :product, through: :product_variant

  has_one_attached :design

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :product_variant, scope: :cart
  validates :calculated_price, presence: true, if: -> { configuration.present? }

  before_validation :set_price_from_variant

  def subtotal_amount
    price * quantity
  end

  def unit_price
    if configuration.present?
      calculated_price / configuration["quantity"]
    else
      product_variant.price
    end
  end

  def line_total
    if configuration.present?
      calculated_price
    else
      product_variant.price * quantity
    end
  end

  def configured?
    configuration.present?
  end

  private

  def set_price_from_variant
    self.price = product_variant.price if product_variant && price.blank?
  end
end
