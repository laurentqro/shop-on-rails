require "test_helper"

class CategoryPositionTest < ActiveSupport::TestCase
  test "categories can be moved lower in position" do
    category1 = categories(:one)
    category2 = categories(:two)

    initial_position = category1.position
    category1.move_lower

    assert category1.position > initial_position
  end

  test "categories can be moved higher in position" do
    category1 = categories(:one)
    category2 = categories(:two)

    category1.move_to_bottom
    initial_position = category1.position
    category1.move_higher

    assert category1.position < initial_position
  end

  test "top category cannot move higher" do
    category = Category.order(:position).first
    initial_position = category.position
    category.move_higher

    assert_equal initial_position, category.position
  end

  test "bottom category cannot move lower" do
    category = Category.order(:position).last
    initial_position = category.position
    category.move_lower

    assert_equal initial_position, category.position
  end
end
