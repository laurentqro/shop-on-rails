require "test_helper"

class ProductOptionValueTest < ActiveSupport::TestCase
  test "valid product option value" do
    value = ProductOptionValue.new(
      product_option: product_options(:size),
      value: "20oz",
      position: 4
    )
    assert value.valid?
  end

  test "requires product_option" do
    value = ProductOptionValue.new(value: "Test")
    assert_not value.valid?
    assert_includes value.errors[:product_option], "must exist"
  end

  test "requires value" do
    value = ProductOptionValue.new(product_option: product_options(:size))
    assert_not value.valid?
    assert_includes value.errors[:value], "can't be blank"
  end

  test "belongs to product option" do
    value = product_option_values(:size_8oz)
    assert_equal product_options(:size), value.product_option
  end

  test "unique value per option" do
    duplicate = ProductOptionValue.new(
      product_option: product_options(:size),
      value: "8oz"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:value], "has already been taken"
  end

  test "same value allowed for different options" do
    # "Small" can exist for both Size and Color (hypothetically)
    value1 = ProductOptionValue.create!(
      product_option: product_options(:size),
      value: "Small"
    )
    value2 = ProductOptionValue.new(
      product_option: product_options(:color),
      value: "Small"
    )
    assert value2.valid?
  end
end
