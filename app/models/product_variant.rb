class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :restrict_with_error
  has_many :order_items, dependent: :nullify

  has_one_attached :image

  scope :active, -> { where(active: true) }
  default_scope { order(:name) }

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :name, presence: true

  delegate :category, :description, :meta_title, :meta_description, :colour, to: :product

  def display_name
    "#{product.name} (#{name})"
  end

  def full_name
    parts = [ product.name ]
    parts << "(#{product.colour})" if product.colour.present?
    parts << "- #{name}" unless name == "Standard" || product.product_variants.count == 1
    parts.join(" ")
  end

  def in_stock?
    stock_quantity > 0
  end

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
end
