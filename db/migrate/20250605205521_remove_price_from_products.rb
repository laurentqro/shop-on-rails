class RemovePriceFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :price
  end
end
