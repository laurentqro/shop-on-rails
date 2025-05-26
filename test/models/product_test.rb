require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup do
    @category = categories(:one)
    # Ensure products(:one) is valid with an SKU for tests that use it directly
    # If your fixture doesn't have it, some tests might need adjustment or direct product creation.
    # For now, tests assume products(:one) has a name 'Product 1' and sku 'SKUONE'
    # and a corresponding slug 'skuone-product-1' in the fixture.
    @product_one = products(:one)
  end

  test "default scope should return active products" do
    assert_equal [ @product_one ], Product.all
  end

  test "should validate presence of name" do
    product = Product.new(sku: "testsku", price: 10, category: @category) # name is nil
    assert_not product.valid?
    assert product.errors[:name].any?
  end

  test "should validate presence of price" do
    product = Product.new(name: "Test Name", sku: "testsku", category: @category) # price is nil
    assert_not product.valid?
    assert product.errors[:price].any?
  end

  test "should validate presence of category" do
    product = Product.new(name: "Test Name", sku: "testsku", price: 10) # category is nil
    assert_not product.valid?
    assert product.errors[:category].any?
  end

  test "should validate presence of sku" do
    product = Product.new(name: "Test Name", price: 10, category: @category) # sku is nil
    assert_not product.valid?
    assert product.errors[:sku].any?
  end

  test "should validate uniqueness of sku" do
    existing_product_sku = @product_one.sku
    product = Product.new(name: "Another Product", sku: existing_product_sku, price: 20, category: @category)
    assert_not product.valid?
    assert product.errors[:sku].any?
  end

  test "should validate numericality of price" do
    product = Product.new(name: "Test Name", sku: "testsku", price: "not a number", category: @category)
    assert_not product.valid?
    assert product.errors[:price].any?
  end

  # Slug generation tests
  test "should generate slug from sku and name on create if slug is blank" do
    product = Product.new(name: "New Awesome Product", sku: "NAP123", price: 10, category: @category)
    assert product.save
    assert_equal "nap123-new-awesome-product", product.slug
  end

  test "should use provided slug on create if slug is present" do
    product = Product.new(name: "New Awesome Product with Slug", sku: "NAPWS456", price: 10, category: @category, slug: "my-custom-slug")
    assert product.save
    assert_equal "my-custom-slug", product.slug
  end

  test "should not change existing slug on update even if name or sku changes" do
    # Assuming @product_one (from fixtures) has sku 'SKUONE', name 'Product 1', and slug 'skuone-product-1'
    original_slug = @product_one.slug
    @product_one.name = "Updated Product Name"
    @product_one.sku = "UPDATEDSKU" # Change SKU as well
    assert @product_one.save
    assert_equal original_slug, @product_one.slug # Slug should not change automatically on update
  end

  test "should regenerate slug on update if slug is manually cleared" do
    # Use a fresh product to avoid fixture state issues and ensure SKU is set for regeneration
    product = Product.create!(name: "Initial Name", sku: "REGENSKU1", price: 10, category: @category)
    # product.slug is now "regensku1-initial-name"

    product.name = "Product For Slug Regeneration"
    product.sku = "REGENSKU2" # SKU might also change
    product.slug = "" # Manually clear the slug
    assert product.save
    assert_equal "regensku2-product-for-slug-regeneration", product.slug
  end

  test "should regenerate slug on update if slug is manually set to nil" do
    product = Product.create!(name: "Initial Nil Name", sku: "NILSKU1", price: 10, category: @category)
    # product.slug is now "nilsku1-initial-nil-name"

    product.name = "Product For Nil Slug Regeneration"
    product.sku = "NILSKU2"
    product.slug = nil # Manually clear the slug by setting to nil
    assert product.save
    assert_equal "nilsku2-product-for-nil-slug-regeneration", product.slug
  end

  test "should save manually updated slug" do
    new_slug = "my-manually-updated-slug"
    @product_one.slug = new_slug
    assert @product_one.save
    assert_equal new_slug, @product_one.slug
  end

  test "should not generate slug if name is blank (validation failure)" do
    product = Product.new(name: "", sku: "NOSLUGSKU1", price: 10, category: @category, slug: "")
    assert_not product.save # Save should fail due to name validation
    assert product.errors[:name].any?
    assert_equal "", product.slug # Slug should remain blank
  end

  test "should not generate slug if sku is blank (validation failure)" do
    product = Product.new(name: "No Slug Name", sku: "", price: 10, category: @category, slug: "")
    assert_not product.save # Save should fail due to sku validation
    assert product.errors[:sku].any?
    assert_equal "", product.slug # Slug should remain blank
  end

  test "should not generate slug if both name and sku are blank (validation failure)" do
    product = Product.new(name: "", sku: "", price: 10, category: @category, slug: "")
    assert_not product.save
    assert product.errors[:name].any?
    assert product.errors[:sku].any?
    assert_equal "", product.slug
  end
end
