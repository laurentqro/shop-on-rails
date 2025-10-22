class CreateBrandedProductPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :branded_product_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.string :size, null: false
      t.integer :quantity_tier, null: false
      t.decimal :price_per_unit, precision: 10, scale: 4, null: false
      t.integer :case_quantity, null: false

      t.timestamps
    end

    add_index :branded_product_prices, [:product_id, :size, :quantity_tier],
              unique: true,
              name: "index_branded_prices_uniqueness"
  end
end
