class CreateProductOptionAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :product_option_assignments do |t|
      t.references :product, null: false, foreign_key: true
      t.references :product_option, null: false, foreign_key: true
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :product_option_assignments, [:product_id, :product_option_id],
              unique: true,
              name: "index_product_option_assignments_uniqueness"
  end
end
