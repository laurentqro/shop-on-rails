class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true
  belongs_to :product_variant, optional: true

  has_one_attached :design

  validates :product_name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :line_total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_line_total

  scope :for_product, ->(product) { where(product: product) }

  def self.create_from_cart_item(cart_item, order)
    order_item = new(
      order: order,
      product: cart_item.product,
      product_variant: cart_item.product_variant,
      product_name: cart_item.product_variant.display_name,
      product_sku: cart_item.product_variant.sku,
      quantity: cart_item.quantity,
      price: cart_item.unit_price,
      line_total: cart_item.line_total,
      configuration: cart_item.configuration
    )

    # Copy design attachment if present
    if cart_item.design.attached?
      order_item.design.attach(cart_item.design.blob)
    end

    order_item
  end

  def subtotal
    price * quantity
  end

  def product_display_name
    product_variant&.name || "Product Unavailable"
  end

  def product_still_available?
    product.present? && product.active?
  end

  def configured?
    configuration.present? && !configuration.empty?
  end

  private

  def calculate_line_total
    self.line_total = subtotal if price.present? && quantity.present?
  end
end
