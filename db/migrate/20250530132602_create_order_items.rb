class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: true
      t.string :product_name, null: false
      t.string :product_sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false
      t.decimal :line_total, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
