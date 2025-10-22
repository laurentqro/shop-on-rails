class BrandedProductPrice < ApplicationRecord
  belongs_to :product

  validates :size, presence: true
  validates :quantity_tier, presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: [:product_id, :size] }
  validates :price_per_unit, presence: true,
            numericality: { greater_than: 0 }
  validates :case_quantity, presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  def total_price
    price_per_unit * quantity_tier
  end

  def self.find_for_configuration(product, size, quantity)
    where(product: product, size: size)
      .where("quantity_tier <= ?", quantity)
      .order(quantity_tier: :desc)
      .first
  end
end
