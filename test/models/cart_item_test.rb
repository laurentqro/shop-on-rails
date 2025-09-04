require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "should not be valid without a cart" do
    cart_item = CartItem.new(product_variant: product_variants(:one))
    assert_not cart_item.valid?
  end

  test "validates quantity" do
    cart_item = CartItem.new(cart: carts(:one), product_variant: product_variants(:one), quantity: 0)
    assert_not cart_item.valid?
  end

  test "validates price" do
    cart_item = CartItem.new(cart: carts(:one), product_variant: product_variants(:one), price: 0)
    assert_not cart_item.valid?
  end

  test "validates uniqueness" do
    cart_item = CartItem.new(cart: carts(:one), product_variant: product_variants(:one), quantity: 1, price: 10)
    assert_not cart_item.valid?
  end
end
