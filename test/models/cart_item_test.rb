require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  setup do
    @cart = Cart.create
    @product_variant = product_variants(:one)
  end

  # Validation tests
  test "should not be valid without a cart" do
    cart_item = CartItem.new(product_variant: @product_variant)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:cart], "must exist"
  end

  test "should not be valid without a product_variant" do
    cart_item = CartItem.new(cart: @cart)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:product_variant], "must exist"
  end

  test "validates quantity is present" do
    cart_item = CartItem.new(cart: @cart, product_variant: @product_variant, quantity: nil)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:quantity], "can't be blank"
  end

  test "validates quantity is greater than zero" do
    cart_item = CartItem.new(cart: @cart, product_variant: @product_variant, quantity: 0)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:quantity], "must be greater than 0"
  end

  test "validates price is greater than zero" do
    cart_item = CartItem.new(cart: @cart, product_variant: @product_variant, quantity: 1, price: 0)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:price], "must be greater than 0"
  end

  test "validates uniqueness of product_variant per cart" do
    cart_item = CartItem.new(cart: carts(:one), product_variant: product_variants(:one), quantity: 1, price: 10)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:product_variant], "has already been taken"
  end

  test "allows same product_variant in different carts" do
    cart1 = Cart.create
    cart2 = Cart.create

    cart_item1 = CartItem.create(cart: cart1, product_variant: @product_variant, quantity: 1, price: 10)
    cart_item2 = CartItem.new(cart: cart2, product_variant: @product_variant, quantity: 1, price: 10)

    assert cart_item2.valid?
  end

  # Method tests
  test "subtotal_amount calculates price times quantity" do
    cart_item = CartItem.new(cart: @cart, product_variant: @product_variant, quantity: 3, price: 10.50)
    assert_equal 31.50, cart_item.subtotal_amount
  end

  test "subtotal_amount handles different quantities" do
    cart_item = CartItem.new(cart: @cart, product_variant: @product_variant, quantity: 1, price: 5.99)
    assert_equal 5.99, cart_item.subtotal_amount
  end

  test "VAT_RATE constant is set" do
    assert_equal 0.2, VAT_RATE
  end

  # Callback tests
  test "automatically sets price from product_variant if blank" do
    cart_item = CartItem.create(cart: @cart, product_variant: @product_variant, quantity: 1)
    assert_equal @product_variant.price, cart_item.price
  end

  test "does not override manually set price" do
    custom_price = 99.99
    cart_item = CartItem.create(cart: @cart, product_variant: @product_variant, quantity: 1, price: custom_price)
    assert_equal custom_price, cart_item.price
  end

  # Association tests
  test "belongs to cart" do
    cart_item = cart_items(:one)
    assert_respond_to cart_item, :cart
    assert_kind_of Cart, cart_item.cart
  end

  test "belongs to product_variant" do
    cart_item = cart_items(:one)
    assert_respond_to cart_item, :product_variant
    assert_kind_of ProductVariant, cart_item.product_variant
  end

  test "has one product through product_variant" do
    cart_item = cart_items(:one)
    assert_respond_to cart_item, :product
    assert_kind_of Product, cart_item.product
  end
end
