class AddMissingIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add index for abandoned cart cleanup queries
    add_index :carts, :created_at

    # Add index for session cleanup queries
    add_index :sessions, :created_at

    # Add index for products.active (used in default scope)
    add_index :products, :active

    # Add index for featured products queries
    add_index :products, :featured

    # Add index for product_variants.active (frequently queried)
    add_index :product_variants, :active
  end
end
