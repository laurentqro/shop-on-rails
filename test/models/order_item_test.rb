require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  setup do
    @order = orders(:one)
    @product_variant = product_variants(:one)
    @valid_attributes = {
      order: @order,
      product_variant: @product_variant,
      product_name: "Test Product",
      product_sku: "TEST-SKU",
      price: 10.99,
      quantity: 2
    }
  end

  # Validation tests
  test "validates presence of product_name" do
    order_item = OrderItem.new(@valid_attributes.except(:product_name))
    assert_not order_item.valid?
    assert_includes order_item.errors[:product_name], "can't be blank"
  end

  test "validates presence of price" do
    order_item = OrderItem.new(@valid_attributes.except(:price))
    assert_not order_item.valid?
    assert_includes order_item.errors[:price], "can't be blank"
  end

  test "validates price is greater than zero" do
    order_item = OrderItem.new(@valid_attributes.merge(price: 0))
    assert_not order_item.valid?
    assert_includes order_item.errors[:price], "must be greater than 0"
  end

  test "validates price is numeric" do
    order_item = OrderItem.new(@valid_attributes.merge(price: -5))
    assert_not order_item.valid?
    assert_includes order_item.errors[:price], "must be greater than 0"
  end

  test "validates presence of quantity" do
    order_item = OrderItem.new(@valid_attributes.except(:quantity))
    assert_not order_item.valid?
    assert_includes order_item.errors[:quantity], "can't be blank"
  end

  test "validates quantity is greater than zero" do
    order_item = OrderItem.new(@valid_attributes.merge(quantity: 0))
    assert_not order_item.valid?
    assert_includes order_item.errors[:quantity], "must be greater than 0"
  end

  test "validates quantity is numeric" do
    order_item = OrderItem.new(@valid_attributes.merge(quantity: -1))
    assert_not order_item.valid?
    assert_includes order_item.errors[:quantity], "must be greater than 0"
  end

  test "validates presence of line_total after calculation" do
    order_item = OrderItem.new(@valid_attributes.merge(line_total: nil))
    order_item.valid?
    assert_not_nil order_item.line_total
  end

  test "validates line_total is non-negative when manually set" do
    # Note: The callback recalculates line_total, so we need to stub the callback
    # or create a specific scenario where it would be negative
    order_item = order_items(:one)

    # Temporarily disable the callback to test validation
    order_item.define_singleton_method(:calculate_line_total) { }
    order_item.line_total = -5

    assert_not order_item.valid?
    assert_includes order_item.errors[:line_total], "must be greater than or equal to 0"
  end

  # Callback tests
  test "calculate_line_total sets line_total before validation" do
    order_item = OrderItem.new(@valid_attributes.merge(price: 10.99, quantity: 3))
    order_item.valid?
    assert_equal 32.97, order_item.line_total
  end

  test "calculate_line_total handles decimal prices correctly" do
    order_item = OrderItem.new(@valid_attributes.merge(price: 5.50, quantity: 4))
    order_item.valid?
    assert_equal 22.0, order_item.line_total
  end

  test "calculate_line_total does not run if price is blank" do
    order_item = OrderItem.new(@valid_attributes.merge(price: nil, quantity: 2, line_total: 100))
    order_item.valid?
    assert_equal 100, order_item.line_total
  end

  test "calculate_line_total does not run if quantity is blank" do
    order_item = OrderItem.new(@valid_attributes.merge(price: 10, quantity: nil, line_total: 100))
    order_item.valid?
    assert_equal 100, order_item.line_total
  end

  # Method tests
  test "subtotal calculates price times quantity" do
    order_item = OrderItem.new(@valid_attributes.merge(price: 15.99, quantity: 3))
    assert_equal 47.97, order_item.subtotal
  end

  test "subtotal handles single quantity" do
    order_item = OrderItem.new(@valid_attributes.merge(price: 9.99, quantity: 1))
    assert_equal 9.99, order_item.subtotal
  end

  test "product_display_name returns variant name when available" do
    order_item = order_items(:one)
    assert_equal order_item.product_variant.name, order_item.product_display_name
  end

  test "product_display_name returns fallback when variant is nil" do
    # product_variant_id is NOT NULL in schema, so this test documents behavior
    # but cannot actually test nil variant due to database constraint
    order_item = order_items(:one)
    # Simulate nil by stubbing the association
    order_item.define_singleton_method(:product_variant) { nil }
    assert_equal "Product Unavailable", order_item.product_display_name
  end

  test "product_still_available? returns true when product exists and is active" do
    order_item = order_items(:one)
    order_item.product.update(active: true)
    assert order_item.product_still_available?
  end

  test "product_still_available? returns false when product is inactive" do
    order_item = order_items(:one)
    order_item.product.update(active: false)
    assert_not order_item.product_still_available?
  end

  # Scope tests
  test "for_product scope filters by product" do
    product = products(:one)
    items = OrderItem.for_product(product)

    # Should return order_items for this product
    assert items.count > 0
    items.each do |item|
      assert_equal product, item.product
    end
  end

  # Association tests
  test "belongs to order" do
    order_item = order_items(:one)
    assert_respond_to order_item, :order
    assert_kind_of Order, order_item.order
  end

  test "belongs to product optionally" do
    order_item = order_items(:one)
    assert_respond_to order_item, :product
    assert_kind_of Product, order_item.product
  end

  test "belongs to product_variant" do
    order_item = order_items(:one)
    assert_respond_to order_item, :product_variant
    assert_kind_of ProductVariant, order_item.product_variant
    # Note: Model says optional: true but schema has NOT NULL constraint
    # Schema constraint prevents actual nil values
  end

  test "order_item requires an order" do
    order_item = OrderItem.new(@valid_attributes.except(:order))
    assert_not order_item.valid?
    assert_includes order_item.errors[:order], "must exist"
  end
end
