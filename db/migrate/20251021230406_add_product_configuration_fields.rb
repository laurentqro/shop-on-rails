class AddProductConfigurationFields < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :product_type, :string, default: "standard", null: false
    add_reference :products, :parent_product, foreign_key: { to_table: :products }
    add_reference :products, :organization, foreign_key: true
    add_column :products, :configuration_data, :jsonb, default: {}

    add_index :products, :product_type
    add_index :products, [:organization_id, :product_type]
  end
end
