class AddConfigurationToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :configuration, :jsonb, default: {}
    add_index :order_items, :configuration, using: :gin
  end
end
