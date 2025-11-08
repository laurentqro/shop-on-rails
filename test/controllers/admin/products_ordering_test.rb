require "test_helper"

class Admin::ProductsOrderingTest < ActionDispatch::IntegrationTest
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
    get order_admin_products_path, headers: @headers
    assert_response :success
    assert_select "h1", "Order Products"
  end

  test "should show products from first category by default" do
    first_category = Category.order(:position).first

    get order_admin_products_path, headers: @headers
    assert_response :success
    assert_select "select#category_id option[selected]", first_category.name
  end

  test "should show products from selected category" do
    category = categories(:hot_cups_extras)

    get order_admin_products_path(category_id: category.id), headers: @headers
    assert_response :success
    assert_select "select#category_id option[selected]", category.name
  end

  test "should move product higher within category" do
    category = categories(:hot_cups_extras)
    products = category.products.order(:position)
    product = products.second
    initial_position = product.position

    patch move_higher_admin_product_path(product), headers: @headers
    assert_redirected_to order_admin_products_path(category_id: category.id)

    assert product.reload.position < initial_position
  end

  test "should move product lower within category" do
    category = categories(:hot_cups_extras)
    products = category.products.order(:position)
    product = products.first
    initial_position = product.position

    patch move_lower_admin_product_path(product), headers: @headers
    assert_redirected_to order_admin_products_path(category_id: category.id)

    assert product.reload.position > initial_position
  end
end
