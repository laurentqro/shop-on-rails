require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = orders(:one)
    @valid_attributes = {
      email: "test@example.com",
      stripe_session_id: "sess_unique_123",
      order_number: "ORD-2025-999999",
      status: "pending",
      subtotal_amount: 100,
      vat_amount: 20,
      shipping_amount: 5,
      total_amount: 125,
      shipping_name: "John Doe",
      shipping_address_line1: "123 Main St",
      shipping_city: "London",
      shipping_postal_code: "SW1A 1AA",
      shipping_country: "GB"
    }
  end

  # Validation tests
  test "validates presence of email" do
    order = Order.new(@valid_attributes.except(:email))
    assert_not order.valid?
    assert_includes order.errors[:email], "can't be blank"
  end

  test "validates email format" do
    order = Order.new(@valid_attributes.merge(email: "invalid-email"))
    assert_not order.valid?
    assert_includes order.errors[:email], "is invalid"
  end

  test "normalizes email to lowercase" do
    order = Order.create!(@valid_attributes.merge(
      email: "TEST@EXAMPLE.COM",
      stripe_session_id: "sess_normalize_test",
      order_number: nil
    ))
    assert_equal "test@example.com", order.email
  end

  test "validates uniqueness of stripe_session_id" do
    order = Order.new(@valid_attributes.merge(stripe_session_id: @order.stripe_session_id))
    assert_not order.valid?
    assert_includes order.errors[:stripe_session_id], "has already been taken"
  end

  test "validates uniqueness of order_number" do
    order = Order.new(@valid_attributes.merge(order_number: @order.order_number))
    assert_not order.valid?
    assert_includes order.errors[:order_number], "has already been taken"
  end

  test "validates presence of required shipping fields" do
    order = Order.new(@valid_attributes.except(:shipping_name))
    assert_not order.valid?
    assert_includes order.errors[:shipping_name], "can't be blank"
  end

  test "validates amounts are non-negative" do
    order = Order.new(@valid_attributes.merge(subtotal_amount: -1))
    assert_not order.valid?
    assert_includes order.errors[:subtotal_amount], "must be greater than or equal to 0"
  end

  # Enum tests
  test "status enum includes all expected values" do
    expected_statuses = %w[pending paid processing shipped delivered cancelled refunded]
    assert_equal expected_statuses.sort, Order.statuses.keys.sort
  end

  test "status enum methods work" do
    @order.status = "shipped"
    assert @order.shipped?
    assert_not @order.pending?
  end

  # Method tests
  test "items_count returns sum of order item quantities" do
    # Check actual fixture data
    expected_count = @order.order_items.sum(:quantity)
    assert_equal expected_count, @order.items_count
  end

  test "full_shipping_address combines address parts" do
    address = @order.full_shipping_address
    assert_includes address, @order.shipping_address_line1
    assert_includes address, @order.shipping_city
    assert_includes address, @order.shipping_postal_code
    assert_includes address, @order.shipping_country
  end

  test "full_shipping_address handles missing address_line2" do
    @order.shipping_address_line2 = nil
    address = @order.full_shipping_address
    assert_not_includes address, "nil"
  end

  test "display_number formats order_number with hash" do
    assert_equal "##{@order.order_number}", @order.display_number
  end

  test "generate_order_number creates unique order number" do
    order = Order.create!(@valid_attributes.except(:order_number))
    assert_not_nil order.order_number
    assert_match /ORD-\d{4}-\d{6}/, order.order_number
  end

  test "generate_order_number includes current year" do
    order = Order.create!(@valid_attributes.except(:order_number).merge(
      stripe_session_id: "sess_year_test"
    ))
    current_year = Date.current.year
    assert_includes order.order_number, current_year.to_s
  end

  test "does not regenerate order_number if already set" do
    order = Order.create!(@valid_attributes)
    original_number = order.order_number
    order.update(subtotal_amount: 200)
    assert_equal original_number, order.order_number
  end

  # Association tests
  test "belongs to user optionally" do
    # Order fixture has user, so test with a new order
    guest_order = Order.create!(@valid_attributes.merge(
      stripe_session_id: "sess_guest_test",
      order_number: nil
    ))
    assert_nil guest_order.user

    guest_order.user = users(:one)
    assert_equal users(:one), guest_order.user
  end

  test "has many order_items" do
    assert_respond_to @order, :order_items
    assert @order.order_items.count > 0
  end

  test "destroying order destroys order_items" do
    order = Order.create!(@valid_attributes.except(:order_number))
    order.order_items.create!(
      product_variant: product_variants(:one),
      product_name: "Test Product",
      product_sku: "TEST123",
      price: 10.0,
      quantity: 1,
      line_total: 10.0
    )

    assert_difference "OrderItem.count", -1 do
      order.destroy
    end
  end

  # Scope tests
  test "recent scope orders by created_at descending" do
    old_order = Order.create!(@valid_attributes.except(:order_number).merge(
      stripe_session_id: "sess_old",
      created_at: 2.days.ago
    ))

    new_order = Order.create!(@valid_attributes.except(:order_number).merge(
      stripe_session_id: "sess_new"
    ))

    recent_orders = Order.recent.limit(2)
    assert_equal new_order, recent_orders.first
  end
end
