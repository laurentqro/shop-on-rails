class RenameSortOrderToPositionOnProductVariants < ActiveRecord::Migration[8.1]
  def change
    # Rename column from sort_order to position
    rename_column :product_variants, :sort_order, :position

    # Update the composite index from (product_id, sort_order) to (product_id, position)
    # Note: PostgreSQL automatically updates indexes when columns are renamed,
    # but the index definition still references the old column name internally.
    # We need to recreate the index to have a clean reference to the new column name.
    remove_index :product_variants, column: [ :product_id, :sort_order ], if_exists: true
    remove_index :product_variants, column: [ :product_id, :position ], if_exists: true
    add_index :product_variants, [ :product_id, :position ], name: "index_product_variants_on_product_id_and_position"
  end
end
