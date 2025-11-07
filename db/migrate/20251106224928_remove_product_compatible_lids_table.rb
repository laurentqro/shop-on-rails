class RemoveProductCompatibleLidsTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :product_compatible_lids do |t|
      t.references :product, null: false, foreign_key: true
      t.references :compatible_lid, null: false, foreign_key: { to_table: :products }
      t.boolean :default, default: false, null: false
      t.integer :sort_order, default: 0, null: false
      t.timestamps
    end
  end
end
