require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Set a modern browser user agent to pass allow_browser check
    @headers = { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    @product = products(:one)
    @admin = users(:acme_admin)
    sign_in_as(@admin)
  end

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }, headers: @headers
  end

  test "should destroy product_photo attachment" do
    # Attach a product photo
    file = fixture_file_upload("test_image.png", "image/png")
    @product.product_photo.attach(file)
    assert @product.product_photo.attached?, "Product photo should be attached before test"

    # Delete the product photo
    delete product_photo_admin_product_path(@product), headers: @headers

    @product.reload
    assert_not @product.product_photo.attached?, "Product photo should be purged after deletion"
  end

  test "should destroy lifestyle_photo attachment" do
    # Attach a lifestyle photo
    file = fixture_file_upload("test_image.png", "image/png")
    @product.lifestyle_photo.attach(file)
    assert @product.lifestyle_photo.attached?, "Lifestyle photo should be attached before test"

    # Delete the lifestyle photo
    delete lifestyle_photo_admin_product_path(@product), headers: @headers

    @product.reload
    assert_not @product.lifestyle_photo.attached?, "Lifestyle photo should be purged after deletion"
  end
end
