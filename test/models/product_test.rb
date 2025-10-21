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
    active_products = Product.all
    assert active_products.include?(@product_one)
    assert_not active_products.include?(products(:two)) # Product two is inactive
  end

  test "should validate presence of name" do
    product = Product.new(sku: "testsku", category: @category) # name is nil
    assert_not product.valid?
    assert product.errors[:name].any?
  end

  test "should validate presence of category" do
    product = Product.new(name: "Test Name", sku: "testsku") # category is nil
    assert_not product.valid?
    assert product.errors[:category].any?
  end

  # Slug generation tests
  test "should generate slug from sku and name on create if slug is blank" do
    product = Product.new(name: "New Awesome Product", sku: "NAP123", category: @category)
    assert product.save
    assert_equal "nap123-new-awesome-product", product.slug
  end

  test "should use provided slug on create if slug is present" do
    product = Product.new(name: "New Awesome Product with Slug", sku: "NAPWS456", category: @category, slug: "my-custom-slug")
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
    product = Product.create!(name: "Initial Name", sku: "REGENSKU1", category: @category)
    # product.slug is now "regensku1-initial-name"

    product.name = "Product For Slug Regeneration"
    product.sku = "REGENSKU2" # SKU might also change
    product.slug = "" # Manually clear the slug
    assert product.save
    assert_equal "regensku2-product-for-slug-regeneration", product.slug
  end

  test "should regenerate slug on update if slug is manually set to nil" do
    product = Product.create!(name: "Initial Nil Name", sku: "NILSKU1", category: @category)
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
    product = Product.new(name: "", sku: "NOSLUGSKU1", category: @category, slug: "")
    assert_not product.save # Save should fail due to name validation
    assert product.errors[:name].any?
    assert_equal "", product.slug # Slug should remain blank
  end

  # Product configuration tests
  test "product types are standard, customizable_template, customized_instance" do
    product = products(:one)

    product.product_type = "standard"
    assert product.valid?

    product.product_type = "customizable_template"
    assert product.valid?

    # customized_instance requires parent_product and organization, so use a proper fixture
    customized_product = products(:acme_branded_cups)
    customized_product.product_type = "customized_instance"
    assert customized_product.valid?

    # Rails enum with validate: true will reject invalid values on validation
    product.product_type = "invalid"
    assert_not product.valid?
    assert_includes product.errors[:product_type], "is not included in the list"
  end

  test "customized_instance requires parent_product_id" do
    product = Product.new(
      name: "Test Instance",
      product_type: "customized_instance",
      parent_product_id: nil
    )
    assert_not product.valid?
    assert_includes product.errors[:parent_product_id], "can't be blank"
  end

  test "customized_instance requires organization_id" do
    product = Product.new(
      name: "Test Instance",
      product_type: "customized_instance",
      parent_product_id: products(:branded_double_wall_template).id,
      organization_id: nil
    )
    assert_not product.valid?
    assert_includes product.errors[:organization_id], "can't be blank"
  end

  test "customized_instance stores configuration_data" do
    product = products(:acme_branded_cups)
    assert_equal "12oz", product.configuration_data["size"]
    assert_equal "double_wall", product.configuration_data["type"]
    assert_equal 5000, product.configuration_data["quantity_ordered"]
  end

  test "standard and template products dont require parent or organization" do
    product = Product.new(
      name: "Test",
      product_type: "standard",
      category: categories(:one)
    )
    assert product.valid?
  end

  test "product has many option assignments" do
    product = products(:single_wall_cups)
    assert_includes product.option_assignments.map(&:product_option), product_options(:size)
  end

  test "product has many options through assignments" do
    product = products(:single_wall_cups)
    assert_includes product.options, product_options(:size)
    assert_includes product.options, product_options(:color)
  end

  test "belongs to organization for customized instances" do
    product = products(:acme_branded_cups)
    assert_equal organizations(:acme), product.organization
  end

  test "belongs to parent product for customized instances" do
    product = products(:acme_branded_cups)
    assert_equal products(:branded_double_wall_template), product.parent_product
  end
end
