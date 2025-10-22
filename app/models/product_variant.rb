# Product variant representing different options of a product (size, volume, pack size)
#
# Variants allow a single product to have multiple purchasable options.
# Each variant has its own SKU, price, and stock level.
#
# Example:
#   Product: "Pizza Box - Kraft"
#   Variants: 7", 9", 10", 12", 14" (each with unique SKU and price)
#
# Key relationships:
# - belongs_to :product - Parent product
# - has_many :cart_items - Items in shopping carts (restricted deletion)
# - has_many :order_items - Items in completed orders (nullified on deletion)
# - has_one_attached :image - Optional variant-specific image
#
# Inheritance:
# - Delegates category, description, meta fields, and colour to parent product
# - Falls back to product image if variant has no specific image
#
# Google Shopping:
# - Each variant becomes a separate item with unique ID (SKU)
# - Variants of same product share item_group_id (product.base_sku)
#
class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :restrict_with_error
  has_many :order_items, dependent: :nullify

  has_one_attached :image

  scope :active, -> { where(active: true) }
  scope :by_name, -> { order(:name) }
  scope :by_sort_order, -> { order(:sort_order, :name) }

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :name, presence: true

  # Inherit these attributes from parent product
  delegate :category, :description, :meta_title, :meta_description, :colour, to: :product

  # Display name for cart/order items
  # Example: "Pizza Box - Kraft (14 inch)"
  def display_name
    "#{product.name} (#{name})"
  end

  # Full product name with variant
  # Omits variant name if it's "Standard" or product has only one variant
  # Example: "Pizza Box - Kraft - 14 inch"
  def full_name
    parts = [ product.name ]
    parts << "- #{name}" unless name == "Standard" || product.active_variants.count == 1
    parts.join(" ")
  end

  # Check if variant is in stock
  # Currently always returns true (stock tracking not implemented)
  # TODO: Implement proper stock tracking based on stock_quantity field
  def in_stock?
    true
    # TODO: Uncomment this when we have stock tracking
    # stock_quantity > 0
  end

  # Returns hash of all product attributes for this variant
  # Used for Google Merchant feed and product detail pages
  # Filters out blank values
  def variant_attributes
    {
      material: "#{product.material}",
      width_in_mm: "#{width_in_mm}",
      height_in_mm: "#{height_in_mm}",
      depth_in_mm: "#{depth_in_mm}",
      weight_in_g: "#{weight_in_g}",
      volume_in_ml: "#{volume_in_ml}",
      diameter_in_mm: "#{diameter_in_mm}"
    }.reject { |_, value| value.blank? }
  end

  # Get value for a specific option
  # Example: variant.option_value_for("size") => "8oz"
  def option_value_for(option_name)
    option_values[option_name]
  end

  # Display string of all option values
  # Example: "8oz White"
  def options_display
    option_values.values.join(" ")
  end

  # Convert pack price to unit price for display
  # If pac_size is set, price is per pack, so divide to get per-unit price
  # Otherwise, price is already per unit
  def unit_price
    return price unless pac_size.present? && pac_size > 0
    price / pac_size
  end

  # Returns minimum order quantity in units
  def minimum_order_units
    pac_size || 1
  end
end
