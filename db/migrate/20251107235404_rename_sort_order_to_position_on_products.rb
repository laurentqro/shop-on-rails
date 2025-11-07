class RenameSortOrderToPositionOnProducts < ActiveRecord::Migration[8.1]
  def change
    rename_column :products, :sort_order, :position
    add_index :products, [ :category_id, :position ], name: "index_products_on_category_id_and_position"
  end
end
