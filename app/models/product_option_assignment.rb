class ProductOptionAssignment < ApplicationRecord
  belongs_to :product
  belongs_to :product_option

  validates :product_option_id, uniqueness: { scope: :product_id }

  default_scope { order(:position) }
end
