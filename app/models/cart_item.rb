class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  has_one :product, through: :product_variant

  has_one_attached :design

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :product_variant, scope: :cart, unless: :configured?
  validates :calculated_price, presence: true, if: :configured?
  validate :design_required_for_configured_products

  before_validation :set_price_from_variant

  def subtotal_amount
    if configured?
      # For configured/branded products: price is already per unit
      price * quantity
    elsif product_variant.pac_size.present? && product_variant.pac_size > 0
      # For standard products with pack pricing:
      # - price is per PACK
      # - quantity is in UNITS
      # Calculate: (units / units_per_pack) * price_per_pack
      packs_needed = (quantity.to_f / product_variant.pac_size).ceil
      price * packs_needed
    else
      # For products without pack size: price is per unit
      price * quantity
    end
  end

  def unit_price
    if configured?
      price
    else
      product_variant.unit_price
    end
  end

  def line_total
    subtotal_amount
  end

  def configured?
    configuration.present?
  end

  private

  def set_price_from_variant
    self.price = product_variant.price if product_variant && price.blank?
  end

  def design_required_for_configured_products
    if configured? && !design.attached?
      errors.add(:design, "must be uploaded for custom products")
    end
  end
end
