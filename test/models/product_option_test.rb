require "test_helper"

class ProductOptionTest < ActiveSupport::TestCase
  test "valid product option" do
    option = ProductOption.new(
      name: "Size",
      display_type: "dropdown",
      required: true,
      position: 1
    )
    assert option.valid?
  end

  test "requires name" do
    option = ProductOption.new(display_type: "dropdown")
    assert_not option.valid?
    assert_includes option.errors[:name], "can't be blank"
  end

  test "requires display_type" do
    option = ProductOption.new(name: "Size")
    assert_not option.valid?
    assert_includes option.errors[:display_type], "can't be blank"
  end

  test "validates display_type values" do
    option = product_options(:size)

    option.display_type = "dropdown"
    assert option.valid?

    option.display_type = "radio"
    assert option.valid?

    option.display_type = "swatch"
    assert option.valid?

    option.display_type = "invalid"
    assert_not option.valid?
  end

  test "has many values" do
    option = product_options(:size)
    assert_includes option.values.map(&:value), "8oz"
    assert_includes option.values.map(&:value), "12oz"
  end

  test "required defaults to true" do
    option = ProductOption.create!(name: "Test", display_type: "dropdown")
    assert option.required?
  end
end
