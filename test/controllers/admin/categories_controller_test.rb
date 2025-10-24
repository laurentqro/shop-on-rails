require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Set a modern browser user agent to pass allow_browser check
    @headers = { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    @category = categories(:cups)
    @admin = users(:acme_admin)
    sign_in_as(@admin)
  end

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }, headers: @headers
  end

  test "should get index" do
    get admin_categories_path, headers: @headers
    assert_response :success
    assert_match /Categories/, response.body
    assert_match @category.name, response.body
  end

  test "should get new" do
    get new_admin_category_path, headers: @headers
    assert_response :success
    assert_match /New Category/, response.body
  end

  test "should create category" do
    assert_difference("Category.count") do
      post admin_categories_path, headers: @headers, params: {
        category: {
          name: "Test Category",
          slug: "test-category",
          description: "A test category",
          meta_title: "Test Category | Afida",
          meta_description: "Test category description"
        }
      }
    end

    assert_redirected_to admin_categories_path
    follow_redirect!
    assert_match /Category was successfully created/, response.body

    # Verify the category was created with correct attributes
    category = Category.find_by(slug: "test-category")
    assert_not_nil category
    assert_equal "Test Category", category.name
    assert_equal "A test category", category.description
  end

  test "should get edit" do
    get edit_admin_category_path(@category), headers: @headers
    assert_response :success
    assert_match /Edit Category/, response.body
    assert_match @category.name, response.body
  end

  test "should update category" do
    patch admin_category_path(@category), headers: @headers, params: {
      category: {
        name: "Updated Name",
        description: "Updated description"
      }
    }

    assert_redirected_to admin_categories_path
    follow_redirect!
    assert_match /Category was successfully updated/, response.body

    @category.reload
    assert_equal "Updated Name", @category.name
    assert_equal "Updated description", @category.description
  end

  test "should update category with image" do
    file = fixture_file_upload("test_image.png", "image/png")

    patch admin_category_path(@category), headers: @headers, params: {
      category: {
        name: @category.name,
        image: file
      }
    }

    assert_redirected_to admin_categories_path

    @category.reload
    assert @category.image.attached?, "Image should be attached"
  end

  test "should destroy category" do
    # Create a category without products for deletion test
    category_to_delete = Category.create!(
      name: "Deletable Category",
      slug: "deletable-category"
    )

    assert_difference("Category.count", -1) do
      delete admin_category_path(category_to_delete), headers: @headers
    end

    assert_redirected_to admin_categories_path
    follow_redirect!
    assert_match /Category was successfully deleted/, response.body
  end

  test "should not create category with invalid data" do
    assert_no_difference("Category.count") do
      post admin_categories_path, headers: @headers, params: {
        category: {
          name: "",
          slug: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not update category with invalid data" do
    original_name = @category.name

    patch admin_category_path(@category), headers: @headers, params: {
      category: {
        name: ""
        # Don't set slug to empty as it causes routing issues
      }
    }

    assert_response :unprocessable_entity

    @category.reload
    assert_equal original_name, @category.name
  end

  test "should use slug in URLs not numeric ID" do
    # Create a category without products for deletion test
    test_category = Category.create!(
      name: "URL Test Category",
      slug: "url-test-category"
    )

    # Edit URL should use slug
    get edit_admin_category_path(test_category.slug), headers: @headers
    assert_response :success

    # Update should work with slug
    patch admin_category_path(test_category.slug), headers: @headers, params: {
      category: { name: "New Name" }
    }
    assert_redirected_to admin_categories_path

    # Delete should work with slug
    delete admin_category_path(test_category.slug), headers: @headers
    assert_redirected_to admin_categories_path
  end
end
