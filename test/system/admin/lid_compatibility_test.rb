require "application_system_test_case"

class Admin::LidCompatibilityTest < ApplicationSystemTestCase
  setup do
    @lid_product = products(:flat_lid_8oz)
    @admin_user = users(:acme_admin)
    sign_in_as(@admin_user)
  end

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
    # Wait for redirect after sign in
    assert_current_path root_path
  end

  test "admin can check and uncheck size checkboxes" do
    visit edit_admin_product_path(@lid_product)

    # Initially the product has ["8oz"] set in fixtures
    checkbox_8oz = find('input[type="checkbox"][value="8oz"]')
    assert checkbox_8oz.checked?

    # Uncheck 8oz
    checkbox_8oz.uncheck

    # Check 12oz
    checkbox_12oz = find('input[type="checkbox"][value="12oz"]')
    refute checkbox_12oz.checked?
    checkbox_12oz.check

    # Submit form
    click_button "Update Product"

    # Verify we're redirected
    assert_current_path admin_products_path
    assert_text "Product was successfully updated"
  end

  test "checkboxes persist after save and reload" do
    visit edit_admin_product_path(@lid_product)

    # Check multiple sizes
    find('input[type="checkbox"][value="8oz"]').check
    find('input[type="checkbox"][value="12oz"]').check
    find('input[type="checkbox"][value="16oz"]').check

    click_button "Update Product"

    # Navigate back to edit page
    visit edit_admin_product_path(@lid_product)

    # Verify all three are still checked
    assert find('input[type="checkbox"][value="8oz"]').checked?
    assert find('input[type="checkbox"][value="12oz"]').checked?
    assert find('input[type="checkbox"][value="16oz"]').checked?

    # Verify others are not checked
    refute find('input[type="checkbox"][value="4oz"]').checked?
    refute find('input[type="checkbox"][value="20oz"]').checked?
  end

  test "multiple sizes can be selected" do
    visit edit_admin_product_path(@lid_product)

    # Scroll to the checkboxes section
    execute_script "window.scrollTo(0, document.body.scrollHeight)"
    sleep 0.5 # Wait for scroll to complete

    # The product fixture already has 8oz checked, so just add more
    # Use click on the label parent element for better compatibility with DaisyUI
    all("label").find { |l| l.text == "4oz" }.find("input").click
    all("label").find { |l| l.text == "12oz" }.find("input").click
    all("label").find { |l| l.text == "16oz" }.find("input").click

    sleep 0.5 # Wait before submitting
    click_button "Update Product"

    # Wait for redirect
    assert_current_path admin_products_path

    # Verify in database - filter out empty strings
    @lid_product.reload
    result = @lid_product.compatible_cup_sizes.reject(&:blank?).sort
    assert_includes result, "4oz"
    assert_includes result, "8oz"
    assert_includes result, "12oz"
    assert_includes result, "16oz"
  end

  test "form submission works correctly" do
    visit edit_admin_product_path(@lid_product)

    # Scroll to the checkboxes section
    execute_script "window.scrollTo(0, document.body.scrollHeight)"
    sleep 0.5

    # Add 12oz to the already-checked 8oz
    all("label").find { |l| l.text == "12oz" }.find("input").click

    sleep 0.5
    click_button "Update Product"

    # Verify redirect and flash message
    assert_current_path admin_products_path
    assert_text "Product was successfully updated"

    # Verify database state - should include at least these two
    @lid_product.reload
    result = @lid_product.compatible_cup_sizes.reject(&:blank?)
    assert_includes result, "8oz"
    assert_includes result, "12oz"
  end
end
