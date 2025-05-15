class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.string :short_description
      t.string :sku
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :vat_rate, precision: 5, scale: 2, default: 20.0
      t.boolean :active, default: true
      t.boolean :sample_eligible, default: false
      t.references :category, null: true, foreign_key: true
      t.string :meta_title
      t.string :meta_description
      t.boolean :featured, default: false
      t.integer :sort_order
      t.integer :pac_size
      t.string :colour
      t.integer :width_in_mm
      t.integer :height_in_mm
      t.integer :depth_in_mm
      t.integer :weight_in_g
      t.integer :volume_in_ml
      t.integer :diameter_in_mm

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
