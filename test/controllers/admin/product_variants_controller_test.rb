require "test_helper"

class Admin::ProductVariantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Set a modern browser user agent to pass allow_browser check
    @headers = { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    @product = products(:one)
    @variant = @product.variants.first
    @admin = users(:acme_admin)
    sign_in_as(@admin)
  end

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }, headers: @headers
  end

  test "should destroy variant product_photo attachment" do
    # Attach a product photo to variant
    file = fixture_file_upload("test_image.png", "image/png")
    @variant.product_photo.attach(file)
    assert @variant.product_photo.attached?, "Variant product photo should be attached before test"

    # Delete the variant product photo
    delete product_photo_admin_product_variant_path(@variant), headers: @headers

    @variant.reload
    assert_not @variant.product_photo.attached?, "Variant product photo should be purged after deletion"
  end

  test "should destroy variant lifestyle_photo attachment" do
    # Attach a lifestyle photo to variant
    file = fixture_file_upload("test_image.png", "image/png")
    @variant.lifestyle_photo.attach(file)
    assert @variant.lifestyle_photo.attached?, "Variant lifestyle photo should be attached before test"

    # Delete the variant lifestyle photo
    delete lifestyle_photo_admin_product_variant_path(@variant), headers: @headers

    @variant.reload
    assert_not @variant.lifestyle_photo.attached?, "Variant lifestyle photo should be purged after deletion"
  end
end
