require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "total_amount" do
    cart = carts(:one)
    assert_equal 20, cart.total_amount
  end
end
