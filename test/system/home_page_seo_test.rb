require "application_system_test_case"

class HomePageSeoTest < ApplicationSystemTestCase
  test "home page has title tag" do
    visit root_path
    assert_title "Premium Eco-Friendly Catering Supplies | Afida"
  end

  test "home page has meta description" do
    visit root_path

    meta_desc = page.find('meta[name="description"]', visible: false)
    assert_includes meta_desc[:content], "sustainable catering supplies"
  end

  test "home page has Open Graph tags" do
    visit root_path

    og_title = page.find('meta[property="og:title"]', visible: false)
    assert_equal "Premium Eco-Friendly Catering Supplies | Afida", og_title[:content]

    og_type = page.find('meta[property="og:type"]', visible: false)
    assert_equal "website", og_type[:content]
  end
end
