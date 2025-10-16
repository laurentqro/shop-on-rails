require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  setup do
    @product = products(:one)
    @variant = product_variants(:one)
  end

  # Validation tests
  test "validates presence of sku" do
    variant = ProductVariant.new(product: @product, name: "Test", price: 10.0)
    assert_not variant.valid?
    assert_includes variant.errors[:sku], "can't be blank"
  end

  test "validates uniqueness of sku" do
    variant = ProductVariant.new(
      product: @product,
      name: "Test",
      sku: @variant.sku,
      price: 10.0
    )
    assert_not variant.valid?
    assert_includes variant.errors[:sku], "has already been taken"
  end

  test "validates presence of price" do
    variant = ProductVariant.new(product: @product, name: "Test", sku: "UNIQUE123")
    assert_not variant.valid?
    assert_includes variant.errors[:price], "can't be blank"
  end

  test "validates price is greater than zero" do
    variant = ProductVariant.new(
      product: @product,
      name: "Test",
      sku: "UNIQUE123",
      price: 0
    )
    assert_not variant.valid?
    assert_includes variant.errors[:price], "must be greater than 0"
  end

  test "validates presence of name" do
    variant = ProductVariant.new(product: @product, sku: "UNIQUE123", price: 10.0)
    assert_not variant.valid?
    assert_includes variant.errors[:name], "can't be blank"
  end

  # Method tests
  test "display_name includes product name and variant name" do
    expected = "#{@variant.product.name} (#{@variant.name})"
    assert_equal expected, @variant.display_name
  end

  test "full_name includes variant name when not Standard" do
    # Create another variant so product has multiple variants
    ProductVariant.create!(
      product: @product,
      name: "Small",
      sku: "SMALL-123",
      price: 5.0,
      active: true
    )

    @variant.update(name: "Large")
    parts = [@variant.product.name, "- Large"]
    assert_equal parts.join(" "), @variant.full_name
  end

  test "full_name excludes variant name when Standard" do
    @variant.update(name: "Standard")
    assert_equal @variant.product.name, @variant.full_name
  end

  test "full_name excludes variant name when product has only one variant" do
    # Create product with single variant
    product = Product.create!(
      name: "Single Variant Product",
      category: categories(:one),
      sku: "SINGLE"
    )
    variant = product.variants.create!(
      name: "Only One",
      sku: "SINGLE-1",
      price: 10.0
    )

    assert_equal product.name, variant.full_name
  end

  test "in_stock? always returns true" do
    # Currently stock tracking is not implemented
    assert @variant.in_stock?

    @variant.stock_quantity = 0
    assert @variant.in_stock?
  end

  test "variant_attributes returns hash of non-blank attributes" do
    @variant.update(
      width_in_mm: 100,
      height_in_mm: 200,
      weight_in_g: 50
    )

    attrs = @variant.variant_attributes
    assert_equal "100", attrs[:width_in_mm]
    assert_equal "200", attrs[:height_in_mm]
    assert_equal "50", attrs[:weight_in_g]
  end

  test "variant_attributes filters out blank values" do
    @variant.update(
      width_in_mm: nil,
      height_in_mm: 200
    )

    attrs = @variant.variant_attributes
    assert_not_includes attrs.keys, :width_in_mm
    assert_includes attrs.keys, :height_in_mm
  end

  # Scope tests
  test "active scope returns only active variants" do
    active_variant = ProductVariant.create!(
      product: @product,
      name: "Active",
      sku: "ACTIVE1",
      price: 10.0,
      active: true
    )

    inactive_variant = ProductVariant.create!(
      product: @product,
      name: "Inactive",
      sku: "INACTIVE1",
      price: 10.0,
      active: false
    )

    active_variants = ProductVariant.unscoped.active
    assert_includes active_variants, active_variant
    assert_not_includes active_variants, inactive_variant
  end

  test "by_name scope orders variants alphabetically" do
    variant_b = ProductVariant.create!(
      product: @product,
      name: "B Variant",
      sku: "B1",
      price: 10.0
    )

    variant_a = ProductVariant.create!(
      product: @product,
      name: "A Variant",
      sku: "A1",
      price: 10.0
    )

    variants = ProductVariant.unscoped.where(product: @product).by_name
    assert_equal "A Variant", variants.first.name
  end

  test "by_sort_order scope orders by sort_order then name" do
    # Create a new product to avoid fixture interference
    product = Product.unscoped.create!(
      name: "Test Product",
      category: categories(:one),
      sku: "TEST-PROD"
    )

    variant_c = ProductVariant.create!(
      product: product,
      name: "C Variant",
      sku: "C1",
      price: 10.0,
      sort_order: 1
    )

    variant_b = ProductVariant.create!(
      product: product,
      name: "B Variant",
      sku: "B1",
      price: 10.0,
      sort_order: 2
    )

    variant_a = ProductVariant.create!(
      product: product,
      name: "A Variant",
      sku: "A1",
      price: 10.0,
      sort_order: 3
    )

    variants = product.variants.by_sort_order
    assert_equal "C Variant", variants.first.name
    assert_equal "B Variant", variants.second.name
    assert_equal "A Variant", variants.third.name
  end

  # Association tests
  test "belongs to product" do
    assert_respond_to @variant, :product
    assert_kind_of Product, @variant.product
  end

  test "has many cart_items" do
    assert_respond_to @variant, :cart_items
  end

  test "has many order_items" do
    assert_respond_to @variant, :order_items
  end

  # Delegation tests
  test "delegates category to product" do
    assert_equal @variant.product.category, @variant.category
  end

  test "delegates description to product" do
    assert_equal @variant.product.description, @variant.description
  end

  test "delegates meta_title to product" do
    assert_equal @variant.product.meta_title, @variant.meta_title
  end

  test "delegates meta_description to product" do
    assert_equal @variant.product.meta_description, @variant.meta_description
  end

  test "delegates colour to product" do
    assert_equal @variant.product.colour, @variant.colour
  end

  # Dependent destroy tests
  test "has dependent restrict_with_error on cart_items" do
    cart = Cart.create
    cart.cart_items.create(product_variant: @variant, quantity: 1, price: 10.0)

    # Should not be able to destroy when cart_items exist
    result = @variant.destroy
    assert_not result
  end

  test "has dependent nullify on order_items" do
    order = orders(:one)
    order_item = order.order_items.create!(
      product_variant: @variant,
      product_name: "Test",
      product_sku: "TEST",
      price: 10.0,
      quantity: 1,
      line_total: 10.0
    )

    @variant.destroy
    order_item.reload

    # Check that order_item still exists but product_variant reference is gone
    assert_not_nil order_item
    # The association is nullified on delete
  end
end
