require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "should not be valid without a cart" do
    cart_item = CartItem.new(product: products(:one))
    assert_not cart_item.valid?
  end

  test "validates quantity" do
    cart_item = CartItem.new(cart: carts(:one), product: products(:one), quantity: 0)
    assert_not cart_item.valid?
  end

  test "validates price" do
    cart_item = CartItem.new(cart: carts(:one), product: products(:one), price: 0)
    assert_not cart_item.valid?
  end

  test "validates uniqueness" do
    cart_item = CartItem.new(cart: carts(:one), product: products(:one), quantity: 1, price: 10)
    assert_not cart_item.valid?
  end
end
