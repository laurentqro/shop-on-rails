class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, :product_sku, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :line_total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_line_total

  scope :for_product, ->(product) { where(product: product) }

  def subtotal
    price * quantity
  end

  def product_display_name
    product_name || product&.name || "Product Unavailable"
  end

  def product_still_available?
    product.present? && product.active?
  end

  private

  def calculate_line_total
    self.line_total = subtotal if price.present? && quantity.present?
  end
end
