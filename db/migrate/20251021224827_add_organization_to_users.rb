class AddOrganizationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :organization, foreign_key: true

    # Remove default value from role column since it should be conditional
    change_column_default :users, :role, from: "customer", to: nil

    add_index :users, [ :organization_id, :role ]
  end
end
