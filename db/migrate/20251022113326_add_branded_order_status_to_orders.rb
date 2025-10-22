class AddBrandedOrderStatusToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :branded_order_status, :string
    add_index :orders, :branded_order_status
  end
end
