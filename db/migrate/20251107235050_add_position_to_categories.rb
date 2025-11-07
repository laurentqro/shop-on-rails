class AddPositionToCategories < ActiveRecord::Migration[8.1]
  def up
    add_column :categories, :position, :integer
    add_index :categories, :position

    # Backfill positions based on current name order
    Category.order(:name).each.with_index(1) do |category, index|
      category.update_column(:position, index)
    end

    change_column_null :categories, :position, false
  end

  def down
    remove_index :categories, :position
    remove_column :categories, :position
  end
end
