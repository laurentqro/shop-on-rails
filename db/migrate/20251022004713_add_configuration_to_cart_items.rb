class AddConfigurationToCartItems < ActiveRecord::Migration[8.0]
  def change
    add_column :cart_items, :configuration, :jsonb, default: {}
    add_column :cart_items, :calculated_price, :decimal, precision: 10, scale: 2

    add_index :cart_items, :configuration, using: :gin
  end
end
