class AddGtinToProductVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :product_variants, :gtin, :string
    add_index :product_variants, :gtin, unique: true, where: "gtin IS NOT NULL"
  end
end
