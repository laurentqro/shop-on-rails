require "test_helper"

class ProductVariantGeneratorServiceTest < ActiveSupport::TestCase
  setup do
    @product = products(:single_wall_cups)
    # Clear any existing variants from fixtures
    @product.variants.destroy_all
    @service = ProductVariantGeneratorService.new(@product)
  end

  test "generates variants for all option combinations" do
    # Product has Size (3 values) and Color (2 values) = 6 combinations
    assert_difference "ProductVariant.count", 6 do
      result = @service.generate_variants(base_price: 26.00, base_stock: 1000)
      assert result.success?
    end
  end

  test "creates variant for each option combination" do
    result = @service.generate_variants(base_price: 26.00, base_stock: 1000)

    variants = @product.variants.reload

    # Should have 8oz White, 8oz Black, 12oz White, 12oz Black, 16oz White, 16oz Black
    assert variants.any? { |v| v.option_values == { "Size" => "8oz", "Color" => "White" } }
    assert variants.any? { |v| v.option_values == { "Size" => "8oz", "Color" => "Black" } }
    assert variants.any? { |v| v.option_values == { "Size" => "12oz", "Color" => "White" } }
  end

  test "generates unique SKUs for each variant" do
    @service.generate_variants(base_price: 26.00, base_stock: 1000)

    skus = @product.variants.pluck(:sku)
    assert_equal skus.uniq.size, skus.size # All unique
  end

  test "SKU includes option values" do
    result = @service.generate_variants(base_price: 26.00, base_stock: 1000)

    variant = @product.variants.find_by("option_values @> ?", { Size: "8oz", Color: "White" }.to_json)
    assert_match /8/, variant.sku
    assert_match /WHI/i, variant.sku # "White" becomes "WHI" (first 3 chars)
  end

  test "applies base price to all variants" do
    @service.generate_variants(base_price: 30.00, base_stock: 500)

    @product.variants.each do |variant|
      assert_equal BigDecimal("30.00"), variant.price
    end
  end

  test "applies base stock to all variants" do
    @service.generate_variants(base_price: 26.00, base_stock: 2000)

    @product.variants.each do |variant|
      assert_equal 2000, variant.stock_quantity
    end
  end

  test "accepts custom price and stock per variant" do
    pricing = {
      { "Size" => "8oz", "Color" => "White" } => { price: 26.00, stock: 1000 },
      { "Size" => "12oz", "Color" => "White" } => { price: 28.00, stock: 1500 }
    }

    result = @service.generate_variants(pricing: pricing, base_price: 20.00, base_stock: 500)

    variant_8oz = @product.variants.find_by("option_values @> ?", { Size: "8oz", Color: "White" }.to_json)
    assert_equal BigDecimal("26.00"), variant_8oz.price
    assert_equal 1000, variant_8oz.stock_quantity

    variant_12oz = @product.variants.find_by("option_values @> ?", { Size: "12oz", Color: "White" }.to_json)
    assert_equal BigDecimal("28.00"), variant_12oz.price
    assert_equal 1500, variant_12oz.stock_quantity
  end

  test "returns error if product has no options" do
    product = products(:branded_double_wall_template) # No option assignments
    service = ProductVariantGeneratorService.new(product)

    result = service.generate_variants(base_price: 10.00, base_stock: 100)

    assert_not result.success?
    assert_includes result.error, "options"
  end

  test "skips existing variants" do
    # Create one variant manually
    @product.variants.create!(
      sku: "EXISTING-001",
      name: "8oz White",
      price: 26.00,
      stock_quantity: 1000,
      option_values: { "Size" => "8oz", "Color" => "White" }
    )

    # Should only create 5 more (6 total - 1 existing)
    assert_difference "ProductVariant.count", 5 do
      @service.generate_variants(base_price: 26.00, base_stock: 1000)
    end
  end

  test "returns variants_created count in result" do
    result = @service.generate_variants(base_price: 26.00, base_stock: 1000)

    assert result.success?
    assert_equal 6, result.variants_created
  end
end
