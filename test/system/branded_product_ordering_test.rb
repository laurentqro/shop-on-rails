require "application_system_test_case"

class BrandedProductOrderingTest < ApplicationSystemTestCase
  setup do
    @acme_admin = users(:acme_admin)
    @product = products(:branded_double_wall_template)
  end

  test "complete branded product order workflow" do
    sign_in_as @acme_admin

    # Browse to branded product
    visit product_path(@product)

    # Verify configurator displayed
    assert_selector "h1", text: @product.name
    assert_selector "[data-controller='branded-configurator']"

    # Step 1: Select size
    click_button "12oz"
    assert_selector ".btn-primary", text: "12oz"

    # Step 2: Select quantity
    within "[data-quantity='5000']" do
      click
    end

    # Wait for price calculation
    assert_selector "[data-branded-configurator-target='total']", text: /£/, wait: 5

    # Step 3: Upload design
    attach_file "design", Rails.root.join("test", "fixtures", "files", "test_design.pdf")
    assert_text "test_design.pdf"

    # Verify add to cart button is enabled
    assert_selector ".btn-primary:not(.btn-disabled)", text: "Add to Cart"

    # Step 4: Add to cart
    click_button "Add to Cart"

    # Verify redirect to cart
    assert_current_path cart_path

    # Verify cart contains configured product
    assert_text "12oz"
    assert_text "5,000"
  end

  test "validates all configurator steps must be completed" do
    sign_in_as @acme_admin
    visit product_path(@product)

    # Initially add to cart should be disabled (no selections)
    assert_selector ".btn-disabled", text: "Add to Cart"

    # Select size only
    click_button "12oz"

    # Still disabled (missing quantity and design)
    assert_selector ".btn-disabled", text: "Add to Cart"

    # Select quantity
    within "[data-quantity='1000']" do
      click
    end

    # Still disabled (missing design)
    assert_selector ".btn-disabled", text: "Add to Cart"

    # Upload design
    attach_file "design", Rails.root.join("test", "fixtures", "files", "test_design.pdf")

    # Now enabled
    assert_selector ".btn-primary:not(.btn-disabled)", text: "Add to Cart"
  end

  test "organization member can view and reorder branded products" do
    sign_in_as @acme_admin

    # Navigate to organization products
    visit organizations_products_path

    assert_selector "h1", text: "Your Branded Products"
    assert_selector ".product-card", count: 1 # acme_branded_cups

    # Click on product
    click_link products(:acme_branded_cups).name

    # Verify show page
    assert_text "12oz"
    assert_text products(:acme_branded_cups).active_variants.first.sku

    # Change quantity and add to cart
    fill_in "Quantity", with: 2000
    click_button "Add to Cart"

    # Verify in cart
    assert_current_path cart_path
    assert_text products(:acme_branded_cups).name
  end

  private

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign In"
  end
end
