require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "total_price" do
    cart = carts(:one)
    assert_equal 20, cart.total_price
  end
end
