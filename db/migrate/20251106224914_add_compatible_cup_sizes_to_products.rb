class AddCompatibleCupSizesToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :compatible_cup_sizes, :string, array: true, default: []
  end
end
