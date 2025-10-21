class CreateProductOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :product_options do |t|
      t.string :name, null: false
      t.string :display_type, null: false
      t.boolean :required, default: true, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :product_options, :position
  end
end
