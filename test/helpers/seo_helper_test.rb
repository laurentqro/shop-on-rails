require "test_helper"

class SeoHelperTest < ActionView::TestCase
  test "generates product JSON-LD structured data" do
    product = products(:single_wall_cups)
    variant = product.active_variants.first

    json = product_structured_data(product, variant)
    data = JSON.parse(json)

    assert_equal "https://schema.org/", data["@context"]
    assert_equal "Product", data["@type"]
    assert_equal product.name, data["name"]
    assert_equal "Afida", data["brand"]["name"]
    assert_includes json, "offers"
  end

  test "generates organization JSON-LD structured data" do
    json = organization_structured_data
    data = JSON.parse(json)

    assert_equal "Organization", data["@type"]
    assert_equal "Afida", data["name"]
    assert_includes json, "contactPoint"
  end

  test "generates breadcrumb JSON-LD structured data" do
    items = [
      { name: "Home", url: root_url },
      { name: "Category", url: category_url("cups") }
    ]

    json = breadcrumb_structured_data(items)
    data = JSON.parse(json)

    assert_equal "BreadcrumbList", data["@type"]
    assert_equal 2, data["itemListElement"].length
  end
end
