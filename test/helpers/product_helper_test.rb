require "test_helper"

class ProductHelperTest < ActionView::TestCase
  test "compatible_lids_for_cup returns lids compatible with given size" do
    # Fixtures have six lids compatible with 8oz
    lids = compatible_lids_for_cup("8oz")

    assert_equal 6, lids.length

    # Should include the specific 8oz lids from fixtures
    lid_names = lids.map(&:name).sort
    assert_includes lid_names, "Flat Lid - 8oz"
    assert_includes lid_names, "Domed Lid - 8oz"
    assert_includes lid_names, "Sip Lid - 8oz"
  end

  test "compatible_lids_for_cup returns empty array for unknown size" do
    lids = compatible_lids_for_cup("99oz")

    assert_empty lids
  end

  test "compatible_lids_for_cup returns empty array for nil size" do
    lids = compatible_lids_for_cup(nil)

    assert_empty lids
  end

  test "compatible_lids_for_cup returns empty array for blank size" do
    lids = compatible_lids_for_cup("")

    assert_empty lids
  end

  test "compatible_lids_for_cup only returns products with active variants" do
    # Create a lid product with compatible size but no active variants
    lid_no_variants = Product.create!(
      name: "Test Lid No Variants",
      slug: "test-lid-no-variants",
      category: categories(:hot_cups_extras),
      active: true,
      product_type: "standard",
      compatible_cup_sizes: [ "8oz" ]
    )

    # Should not appear in results because it has no active variants
    lids = compatible_lids_for_cup("8oz")
    refute_includes lids.map(&:id), lid_no_variants.id

    # Now add an active variant
    lid_no_variants.variants.create!(
      name: "Standard",
      sku: "TEST-LID-001",
      price: 10.00,
      active: true
    )

    # Now it should appear
    lids = compatible_lids_for_cup("8oz")
    assert_includes lids.map(&:id), lid_no_variants.id
  end

  test "compatible_lids_for_cup uses database compatible_cup_sizes column" do
    # Update a lid to have different compatible sizes
    lid = products(:flat_lid_8oz)
    lid.update!(compatible_cup_sizes: [ "12oz", "16oz" ])

    # Should not find it for 8oz anymore
    lids_8oz = compatible_lids_for_cup("8oz")
    refute_includes lids_8oz.map(&:id), lid.id

    # Should find it for 12oz
    lids_12oz = compatible_lids_for_cup("12oz")
    assert_includes lids_12oz.map(&:id), lid.id

    # Should find it for 16oz
    lids_16oz = compatible_lids_for_cup("16oz")
    assert_includes lids_16oz.map(&:id), lid.id
  end

  test "compatible_lids_for_cup only returns standard product type" do
    # Fixtures use product_type: standard for lids
    lids = compatible_lids_for_cup("8oz")

    lids.each do |lid|
      assert_equal "standard", lid.product_type
    end
  end
end
