require "test_helper"

class ProductPositionTest < ActiveSupport::TestCase
  test "products can be moved higher within their category" do
    category = categories(:hot_cups_extras)
    products = category.products.order(:position).limit(2)
    product2 = products.second

    initial_position = product2.position
    product2.move_higher

    assert product2.position < initial_position
  end

  test "products can be moved lower within their category" do
    category = categories(:hot_cups_extras)
    products = category.products.order(:position).limit(2)
    product1 = products.first

    initial_position = product1.position
    product1.move_lower

    assert product1.position > initial_position
  end

  test "product position is scoped to category" do
    cups_category = categories(:cups)
    branded_category = categories(:branded)

    cups_product = cups_category.products.first
    branded_product = branded_category.products.first

    # Both can be position 1 in different categories
    cups_product.update(position: 1)
    branded_product.update(position: 1)

    assert_equal 1, cups_product.reload.position
    assert_equal 1, branded_product.reload.position
  end

  test "moving product to different category updates positions" do
    old_category = categories(:cups)
    new_category = categories(:branded)
    product = old_category.products.first

    product.update(category: new_category)

    # Should be added to bottom of new category
    assert_equal new_category.products.maximum(:position), product.position
  end
end
