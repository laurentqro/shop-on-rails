class ProductCompatibleLid < ApplicationRecord
  belongs_to :product
  belongs_to :compatible_lid, class_name: "Product"

  validates :compatible_lid_id, uniqueness: { scope: :product_id }

  default_scope { order(:sort_order) }

  before_save :ensure_single_default, if: :default?

  private

  def ensure_single_default
    ProductCompatibleLid
      .where(product_id: product_id, default: true)
      .where.not(id: id)
      .update_all(default: false)
  end
end
