class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :billing_email, null: false
      t.string :phone
      t.jsonb :default_shipping_address, default: {}

      t.timestamps
    end

    add_index :organizations, :billing_email
  end
end
