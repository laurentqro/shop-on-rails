class CreateProductOptionValues < ActiveRecord::Migration[8.0]
  def change
    create_table :product_option_values do |t|
      t.references :product_option, null: false, foreign_key: true
      t.string :value, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :product_option_values, [ :product_option_id, :value ], unique: true
    add_index :product_option_values, :position
  end
end
