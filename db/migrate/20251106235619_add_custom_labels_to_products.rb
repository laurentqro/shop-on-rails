class AddCustomLabelsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :profit_margin, :string
    add_column :products, :best_seller, :boolean, default: false
    add_column :products, :seasonal_type, :string, default: "year_round"
    add_column :products, :b2b_priority, :string

    add_index :products, :best_seller
    add_index :products, :profit_margin
  end
end
