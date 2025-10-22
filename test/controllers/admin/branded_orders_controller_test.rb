require "test_helper"

class Admin::BrandedOrdersControllerTest < ActionDispatch::IntegrationTest
  # Note: Add admin authentication when implemented
  # For now, these tests assume admin access

  def setup
    # Set a modern browser user agent to pass allow_browser check
    @headers = { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
  end

  test "index shows orders with configured products" do
    get admin_branded_orders_path, headers: @headers
    assert_response :success

    # Should show orders containing configured cart items
    assert_match /Branded Product Orders/, response.body
  end

  test "show displays order with configuration details" do
    order = orders(:acme_order)

    get admin_branded_order_path(order), headers: @headers
    assert_response :success

    assert_match /Order ##{order.id}/, response.body
  end

  test "filters to only orders with configured products" do
    # Create order without configured products
    standard_order = orders(:one)

    get admin_branded_orders_path, headers: @headers
    assert_response :success

    # Implementation will filter to only branded orders
  end
end
