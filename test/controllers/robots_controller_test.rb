require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  test "should get robots txt" do
    get "/robots.txt"
    assert_response :success
    assert_equal "text/plain; charset=utf-8", response.content_type
  end

  test "robots txt includes sitemap" do
    get "/robots.txt"
    assert_includes response.body, "Sitemap:"
    assert_includes response.body, "/sitemap.xml"
  end

  test "robots txt disallows admin" do
    get "/robots.txt"
    assert_includes response.body, "Disallow: /admin/"
  end
end
