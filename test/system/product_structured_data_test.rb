require "application_system_test_case"

class ProductStructuredDataTest < ApplicationSystemTestCase
  test "product page includes product structured data" do
    product = products(:single_wall_cups)
    visit product_path(product)

    # Check directly in HTML source since Capybara may not parse script content
    page_html = page.html
    assert_includes page_html, '"@type":"Product"', "No Product structured data found in HTML"
    assert_includes page_html, product.name, "Product name not in structured data"
  end

  test "product page includes breadcrumb structured data" do
    product = products(:single_wall_cups)
    visit product_path(product)

    page_html = page.html
    assert_includes page_html, '"@type":"BreadcrumbList"', "No BreadcrumbList structured data found"
    assert_includes page_html, "Home", "Home not in breadcrumb"
    assert_includes page_html, product.category.name, "Category name not in breadcrumb"
  end
end
