class AddMaterialToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :material, :string
  end
end
