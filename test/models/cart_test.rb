require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = carts(:one)
    @empty_cart = Cart.create
    @guest_cart = Cart.create
    @user_cart = Cart.create(user: users(:one))
  end

  test "items_count returns number of distinct cart items" do
    assert_equal 1, @cart.items_count  # Changed: counts distinct items, not quantity sum
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

    # After reload, count is recalculated (distinct items, not quantity sum)
    @cart.reload
    assert_equal 2, @cart.items_count  # Changed: 2 distinct items total
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
    assert_equal 1, @cart.items_count  # Changed: counts distinct items
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

  # Pack-based pricing tests
  test "subtotal_amount calculates correctly for standard product with pack pricing" do
    cart = Cart.create
    product = products(:one)

    # Create variant with pack pricing: £100 per pack of 1000 units
    variant = ProductVariant.create!(
      product: product,
      name: "1000 pack",
      sku: "TEST-CART-PACK-1000",
      price: 100.00,
      pac_size: 1000,
      active: true
    )

    # Add 1500 units to cart (requires 2 packs)
    cart.cart_items.create!(
      product_variant: variant,
      quantity: 1500,
      price: variant.price
    )

    # Should calculate: 2 packs × £100 = £200
    assert_equal 200.00, cart.subtotal_amount
    assert_equal 40.00, cart.vat_amount  # 20% of £200
    assert_equal 240.00, cart.total_amount
  end

  test "subtotal_amount with multiple pack-based products" do
    cart = Cart.create

    # First standard product with pack pricing
    product1 = products(:one)
    variant1 = ProductVariant.create!(
      product: product1,
      name: "500 pack",
      sku: "TEST-CART-PACK-500",
      price: 50.00,
      pac_size: 500,
      active: true
    )

    # Second standard product with different pack pricing
    product2 = products(:two)
    variant2 = ProductVariant.create!(
      product: product2,
      name: "1000 pack",
      sku: "TEST-CART-PACK-1000",
      price: 80.00,
      pac_size: 1000,
      active: true
    )

    # Add first product: 750 units (needs 2 packs) = £100
    cart.cart_items.create!(
      product_variant: variant1,
      quantity: 750,
      price: variant1.price
    )

    # Add second product: 2500 units (needs 3 packs) = £240
    cart.cart_items.create!(
      product_variant: variant2,
      quantity: 2500,
      price: variant2.price
    )

    # Total: £100 + £240 = £340
    assert_equal 340.00, cart.subtotal_amount
    assert_equal 68.00, cart.vat_amount  # 20% of £340
    assert_equal 408.00, cart.total_amount
  end
end
