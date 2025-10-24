class AddProductsCountToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :products_count, :integer, default: 0, null: false

    # Backfill existing counts
    reversible do |dir|
      dir.up do
        Category.find_each do |category|
          Category.reset_counters(category.id, :products)
        end
      end
    end
  end
end
