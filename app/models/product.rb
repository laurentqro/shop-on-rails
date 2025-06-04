class Product < ApplicationRecord
  default_scope { where(active: true).order(:sort_order, :id) }
  scope :featured, -> { where(featured: true) }

  belongs_to :category
  has_many :variants, dependent: :destroy, class_name: "ProductVariant"
  has_many :active_variants, -> { active }, class_name: "ProductVariant"

  has_one_attached :image

  before_validation :generate_slug

  validates :name, :category, presence: true
  validates :slug, presence: true, uniqueness: true

  def generate_slug
    if slug.blank? && name.present?
      slug_parts = [ sku, name, colour ].compact.reject(&:blank?).join(" ")
      self.slug = slug_parts.parameterize
    end
  end

  def to_param
    slug
  end

  def default_variant
    active_variants.first
  end

  def price_range
    prices = active_variants.pluck(:price)
    return nil if prices.empty?

    min = prices.min
    max = prices.max

    min == max ? min : [ min, max ]
  end
end
