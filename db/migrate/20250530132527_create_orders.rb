class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: true, foreign_key: true
      t.string :email, null: false
      t.string :stripe_session_id, null: false
      t.string :order_number, null: false
      t.string :status, null: false, default: "pending"
      t.decimal :subtotal_amount, precision: 10, scale: 2, null: false
      t.decimal :vat_amount, precision: 10, scale: 2, null: false
      t.decimal :shipping_amount, precision: 10, scale: 2, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :shipping_name, null: false
      t.string :shipping_address_line1, null: false
      t.string :shipping_address_line2
      t.string :shipping_city, null: false
      t.string :shipping_postal_code, null: false
      t.string :shipping_country, null: false

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :stripe_session_id, unique: true
    add_index :orders, :status
    add_index :orders, :email
  end
end
