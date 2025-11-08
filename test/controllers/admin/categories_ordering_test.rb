require "test_helper"

class Admin::CategoriesOrderingTest < ActionDispatch::IntegrationTest
  def setup
    # Set a modern browser user agent to pass allow_browser check
    @headers = { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    @admin = users(:acme_admin)
    sign_in_as(@admin)
  end

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }, headers: @headers
  end

  test "should get order page" do
    get order_admin_categories_path, headers: @headers
    assert_response :success
    assert_select "h1", "Order Categories"
  end

  test "should move category higher" do
    category = categories(:two)
    initial_position = category.position

    patch move_higher_admin_category_path(category), headers: @headers
    assert_redirected_to order_admin_categories_path

    assert category.reload.position < initial_position
  end

  test "should move category lower" do
    category = categories(:one)
    initial_position = category.position

    patch move_lower_admin_category_path(category), headers: @headers
    assert_redirected_to order_admin_categories_path

    assert category.reload.position > initial_position
  end

  test "should respond with turbo stream for move_higher" do
    category = categories(:two)

    patch move_higher_admin_category_path(category),
      headers: @headers.merge({ "Accept" => "text/vnd.turbo-stream.html" })

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end
end
