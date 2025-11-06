require "application_system_test_case"

class SeoTest < ApplicationSystemTestCase
  test "product pages have canonical URLs" do
    product = products(:single_wall_cups)
    visit product_path(product)

    canonical = page.find('link[rel="canonical"]', visible: false)
    assert_includes canonical[:href], product_path(product)
  end

  test "category pages have canonical URLs" do
    category = categories(:cups)
    visit category_path(category)

    canonical = page.find('link[rel="canonical"]', visible: false)
    assert_includes canonical[:href], category_path(category)
  end
end
