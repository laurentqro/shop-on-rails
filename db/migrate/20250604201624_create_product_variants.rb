class CreateProductVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :length_in_mm
      t.integer :height_in_mm
      t.integer :width_in_mm
      t.integer :depth_in_mm
      t.integer :weight_in_g
      t.integer :volume_in_ml
      t.integer :diameter_in_mm
      t.integer :pac_size
      t.boolean :active, default: true
      t.integer :sort_order, default: 0
      t.integer :stock_quantity, default: 0

      t.timestamps
    end

    add_index :product_variants, [ :product_id, :sku ], unique: true
    add_index :product_variants, [ :product_id, :sort_order ]
  end
end
