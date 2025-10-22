require "test_helper"

class BrandedProducts::LidsControllerTest < ActionDispatch::IntegrationTest
  test "returns compatible lids for 8oz cups" do
    get branded_products_compatible_lids_path, params: { size: "8oz" }, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert json["lids"].is_a?(Array)
    # Should return products with 80mm lid variants
    assert json["lids"].length > 0, "Expected to find lids for 8oz cups"
    json["lids"].each do |lid|
      assert_match /Lid/i, lid["name"], "Product should be a lid"
    end
  end

  test "returns compatible lids for 12oz cups" do
    get branded_products_compatible_lids_path, params: { size: "12oz" }, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    # Should return products with 90mm lid variants
    assert json["lids"].length > 0, "Expected to find lids for 12oz cups"
    json["lids"].each do |lid|
      assert_match /Lid/i, lid["name"], "Product should be a lid"
    end
  end

  test "returns empty array for invalid size" do
    get branded_products_compatible_lids_path, params: { size: "99oz" }, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal [], json["lids"]
  end

  test "returns lids with required attributes" do
    get branded_products_compatible_lids_path, params: { size: "8oz" }, as: :json

    json = JSON.parse(response.body)
    lid = json["lids"].first

    assert lid["id"].present?
    assert lid["name"].present?
    assert lid["price"].present?
    assert lid["pac_size"].present?
    assert lid["sku"].present?
  end
end
