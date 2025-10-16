require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = carts(:one)
    @empty_cart = Cart.create
    @guest_cart = Cart.create
    @user_cart = Cart.create(user: users(:one))
  end

  test "items_count returns sum of all item quantities" do
    assert_equal 2, @cart.items_count
    assert_equal 0, @empty_cart.items_count
  end

  test "subtotal_amount calculates sum before VAT" do
    assert_equal 20.0, @cart.subtotal_amount
    assert_equal 0, @empty_cart.subtotal_amount
  end

  test "vat_amount calculates 20% VAT on subtotal" do
    assert_equal 4.0, @cart.vat_amount
    assert_equal 0, @empty_cart.vat_amount
  end

  test "total_amount includes subtotal plus VAT" do
    assert_equal 24.0, @cart.total_amount
    assert_equal 0, @empty_cart.total_amount
  end

  test "VAT_RATE constant is set to 20%" do
    assert_equal 0.2, VAT_RATE
  end

  test "items_count is memoized within request" do
    # First call caches the value
    count1 = @cart.items_count

    # Add a new item directly to the association without reloading cart
    @cart.cart_items.create!(
      product_variant: product_variants(:two),
      quantity: 5,
      price: 10.0
    )

    # Second call returns cached value (doesn't reflect new item)
    count2 = @cart.items_count
    assert_equal count1, count2

    # After reload, count is recalculated
    @cart.reload
    assert_equal count1 + 5, @cart.items_count
  end

  test "subtotal_amount is memoized within request" do
    # First call caches the value
    subtotal1 = @cart.subtotal_amount

    # Add a new item directly to the association
    @cart.cart_items.create!(
      product_variant: product_variants(:two),
      quantity: 1,
      price: 100.0
    )

    # Second call returns cached value
    subtotal2 = @cart.subtotal_amount
    assert_equal subtotal1, subtotal2

    # After reload, subtotal is recalculated
    @cart.reload
    assert_equal subtotal1 + 100.0, @cart.subtotal_amount
  end

  test "reload clears memoized values" do
    # Trigger memoization
    @cart.items_count
    @cart.subtotal_amount

    # Reload should clear instance variables
    @cart.reload

    # Values should be recalculated on next access
    assert_equal 2, @cart.items_count
    assert_equal 20.0, @cart.subtotal_amount
  end

  test "guest_cart? returns true when user is nil" do
    assert @guest_cart.guest_cart?
  end

  test "guest_cart? returns false when user is present" do
    assert_not @user_cart.guest_cart?
  end

  test "cart belongs to user optionally" do
    assert_nil @guest_cart.user
    assert_equal users(:one), @user_cart.user
  end

  test "cart has many cart_items" do
    assert_respond_to @cart, :cart_items
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @cart.cart_items
  end

  test "destroying cart destroys associated cart_items" do
    cart_with_items = Cart.create
    cart_with_items.cart_items.create(
      product_variant: product_variants(:one),
      quantity: 1,
      price: 10.0
    )

    assert_difference "CartItem.count", -1 do
      cart_with_items.destroy
    end
  end
end
