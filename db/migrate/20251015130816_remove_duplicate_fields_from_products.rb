class RemoveDuplicateFieldsFromProducts < ActiveRecord::Migration[8.0]
  def change
    # Remove duplicate dimension fields from products table
    # These fields exist on product_variants and should be the single source of truth
    remove_column :products, :pac_size, :string
    remove_column :products, :diameter_in_mm, :integer
    remove_column :products, :volume_in_ml, :integer
    remove_column :products, :weight_in_g, :integer
    remove_column :products, :depth_in_mm, :integer
    remove_column :products, :height_in_mm, :integer
    remove_column :products, :width_in_mm, :integer
  end
end
