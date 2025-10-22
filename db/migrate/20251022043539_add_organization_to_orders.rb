class AddOrganizationToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :organization, foreign_key: true
    add_reference :orders, :placed_by_user, foreign_key: { to_table: :users }

    add_index :orders, [ :organization_id, :created_at ]
  end
end
