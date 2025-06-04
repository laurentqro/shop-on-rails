class AddProductVariantIdToCartItems < ActiveRecord::Migration[8.0]
  def change
    remove_reference :cart_items, :product, null: false, foreign_key: true
    add_reference :cart_items, :product_variant, null: false, foreign_key: true
  end
end
