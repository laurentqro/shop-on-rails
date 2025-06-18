class AddBaseSkuToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :base_sku, :string
    add_index :products, :base_sku, unique: true
  end
end