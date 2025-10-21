require "test_helper"

class ProductOptionAssignmentTest < ActiveSupport::TestCase
  test "valid assignment" do
    assignment = ProductOptionAssignment.new(
      product: products(:one),
      product_option: product_options(:material),
      position: 3
    )
    assert assignment.valid?
  end

  test "requires product" do
    assignment = ProductOptionAssignment.new(product_option: product_options(:size))
    assert_not assignment.valid?
    assert_includes assignment.errors[:product], "must exist"
  end

  test "requires product_option" do
    assignment = ProductOptionAssignment.new(product: products(:one))
    assert_not assignment.valid?
    assert_includes assignment.errors[:product_option], "must exist"
  end

  test "unique product_option per product" do
    duplicate = ProductOptionAssignment.new(
      product: products(:one),
      product_option: product_options(:size)
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_option_id], "has already been taken"
  end

  test "same option can be assigned to different products" do
    assignment = ProductOptionAssignment.create!(
      product: products(:two),
      product_option: product_options(:size)
    )
    assert assignment.persisted?
  end
end
