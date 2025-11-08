class RecreateProductCompatibleLids < ActiveRecord::Migration[8.1]
  def up
    # Only create table if it doesn't exist (in case drop migration never ran)
    unless table_exists?(:product_compatible_lids)
      create_table :product_compatible_lids do |t|
        t.references :product, null: false, foreign_key: true
        t.references :compatible_lid, null: false, foreign_key: { to_table: :products }
        t.boolean :default, default: false, null: false
        t.integer :sort_order, default: 0, null: false

        t.timestamps
      end

      add_index :product_compatible_lids, [ :product_id, :compatible_lid_id ],
                unique: true,
                name: 'index_product_compatible_lids_on_product_and_lid'
      add_index :product_compatible_lids, [ :product_id, :sort_order ]
    end
  end

  def down
    drop_table :product_compatible_lids if table_exists?(:product_compatible_lids)
  end
end
