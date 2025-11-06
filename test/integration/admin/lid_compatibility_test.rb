require "test_helper"

class Admin::LidCompatibilityTest < ActionDispatch::IntegrationTest
  setup do
    @lid_product = products(:flat_lid_8oz)
    @admin_user = users(:acme_admin)
    sign_in_as(@admin_user)
  end

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  test "admin can set compatible cup sizes on a lid product" do
    patch admin_product_path(@lid_product), params: {
      product: {
        compatible_cup_sizes: [ "8oz", "12oz" ]
      }
    }

    assert_redirected_to admin_products_path
    @lid_product.reload
    assert_equal [ "8oz", "12oz" ].sort, @lid_product.compatible_cup_sizes.sort
  end

  test "admin can select multiple cup sizes" do
    patch admin_product_path(@lid_product), params: {
      product: {
        compatible_cup_sizes: [ "8oz", "12oz", "16oz" ]
      }
    }

    @lid_product.reload
    assert_equal 3, @lid_product.compatible_cup_sizes.length
    assert_includes @lid_product.compatible_cup_sizes, "8oz"
    assert_includes @lid_product.compatible_cup_sizes, "12oz"
    assert_includes @lid_product.compatible_cup_sizes, "16oz"
  end

  test "admin can view selected cup sizes on edit page" do
    @lid_product.update(compatible_cup_sizes: [ "8oz", "12oz" ])

    get edit_admin_product_path(@lid_product)
    assert_response :success

    # Check that the checkboxes are present
    assert_select 'input[type="checkbox"][value="8oz"]'
    assert_select 'input[type="checkbox"][value="12oz"]'
  end

  test "admin can update cup sizes - add new sizes" do
    @lid_product.update(compatible_cup_sizes: [ "8oz" ])

    patch admin_product_path(@lid_product), params: {
      product: {
        compatible_cup_sizes: [ "8oz", "12oz", "16oz" ]
      }
    }

    @lid_product.reload
    assert_equal [ "8oz", "12oz", "16oz" ].sort, @lid_product.compatible_cup_sizes.sort
  end

  test "admin can update cup sizes - remove sizes" do
    @lid_product.update(compatible_cup_sizes: [ "8oz", "12oz", "16oz" ])

    patch admin_product_path(@lid_product), params: {
      product: {
        compatible_cup_sizes: [ "8oz" ]
      }
    }

    @lid_product.reload
    assert_equal [ "8oz" ], @lid_product.compatible_cup_sizes
  end

  test "saving with no sizes selected clears the array" do
    @lid_product.update(compatible_cup_sizes: [ "8oz", "12oz" ])

    # Empty array in params (the hidden field ensures the parameter is sent)
    patch admin_product_path(@lid_product), params: {
      product: {
        compatible_cup_sizes: [ "" ]
      }
    }

    @lid_product.reload
    # Should be empty or contain only empty string which is filtered out
    assert_empty @lid_product.compatible_cup_sizes.reject(&:blank?)
  end
end
