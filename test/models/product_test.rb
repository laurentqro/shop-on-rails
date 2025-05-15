require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "default scope should return active products" do
    product = products(:one)
    assert_equal [product], Product.all
  end

  test "should validate presence of name" do
    product = products(:one)
    product.name = nil
    assert_not product.valid?
  end

  test "should validate presence of description" do
    product = products(:one)
    product.description = nil
    assert_not product.valid?
  end

  test "should validate presence of price" do
    product = products(:one)
    product.price = nil
    assert_not product.valid?
  end

  test "should validate presence of category" do
    product = products(:one)
    product.category = nil
    assert_not product.valid?
  end

  test "should validate numericality of price" do
    product = products(:one)
    product.price = "not a number"
    assert_not product.valid?
  end
end