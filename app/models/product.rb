# Represents a product in the e-commerce catalog.
#
# Products are the base model for items sold in the shop. Each product can have
# multiple variants (different sizes, volumes, pack sizes) but colors are
# separate products.
#
# Key relationships:
# - belongs_to :category - Product must be in a category
# - has_many :variants - ProductVariant records (different sizes/options)
# - has_one_attached :image - Main product image (Active Storage)
#
# URL structure:
# - Uses slugs for SEO-friendly URLs (generated from name/SKU/colour)
# - Example: /products/pizza-box-kraft
#
# Default scope:
# - Only returns active products ordered by sort_order, then name
# - Use Product.unscoped to access inactive products
#
class Product < ApplicationRecord
  default_scope { where(active: true).order(:sort_order, :name) }
  scope :featured, -> { where(featured: true) }

  belongs_to :category
  has_many :variants, dependent: :destroy, class_name: "ProductVariant"
  has_many :active_variants, -> { active }, class_name: "ProductVariant"

  accepts_nested_attributes_for :variants, allow_destroy: true, reject_if: :all_blank

  has_one_attached :image

  before_validation :generate_slug

  validates :name, :category, presence: true
  validates :slug, presence: true, uniqueness: true

  # Generates a SEO-friendly slug from product attributes
  # Combines SKU, name, and colour to create unique, descriptive URL
  # Example: "PIZB", "Pizza Box", "Kraft" → "pizb-pizza-box-kraft"
  def generate_slug
    if slug.blank? && name.present?
      slug_parts = [ sku, name, colour ].compact.reject(&:blank?).join(" ")
      self.slug = slug_parts.parameterize
    end
  end

  # Override to_param to use slug in URLs instead of ID
  # Makes URLs like /products/pizza-box-kraft instead of /products/123
  def to_param
    slug
  end

  # Returns the first active variant
  # Useful for products with single variants or to show a default option
  def default_variant
    active_variants.first
  end

  # Calculates price range across all active variants
  # Returns:
  # - nil if no variants
  # - Single price if all variants have same price
  # - [min, max] array if variant prices differ
  def price_range
    prices = active_variants.pluck(:price)
    return nil if prices.empty?

    min = prices.min
    max = prices.max

    min == max ? min : [ min, max ]
  end
end
