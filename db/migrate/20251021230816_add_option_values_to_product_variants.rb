class AddOptionValuesToProductVariants < ActiveRecord::Migration[8.0]
  def change
    add_column :product_variants, :option_values, :jsonb, default: {}

    add_index :product_variants, :option_values, using: :gin
  end
end
