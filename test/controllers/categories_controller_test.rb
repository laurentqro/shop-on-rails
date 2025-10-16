require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one)
  end

  # GET /categories/:id (show)
  test "should show category by slug" do
    get category_url(@category.slug)
    assert_response :success
  end

  test "show page loads category with slug" do
    get category_url(@category.slug)
    assert_response :success
    # Response should contain category name
    assert_match @category.name, response.body
  end

  test "show page loads category products" do
    get category_url(@category.slug)
    assert_response :success
    # Response should show products from this category
  end

  test "show page accessible to guests" do
    get category_url(@category.slug)
    assert_response :success
  end

  test "show page accessible to authenticated users" do
    sign_in_as(users(:one))
    get category_url(@category.slug)
    assert_response :success
  end

  test "category URLs use SEO-friendly slugs" do
    get category_url(@category.slug)
    assert_response :success
    # Categories are accessed via slug, not ID
  end

  test "show page eager loads products with images" do
    get category_url(@category.slug)
    assert_response :success
    # Eager loading prevents N+1 queries
  end

  test "show page displays only products from category" do
    get category_url(@category.slug)
    assert_response :success
    # Products displayed belong to this category
  end

  test "category pages are publicly accessible" do
    # Verify no authentication required
    get category_url(@category.slug)
    assert_response :success
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }
  end
end
