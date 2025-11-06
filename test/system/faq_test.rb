# frozen_string_literal: true

require "application_system_test_case"

class FaqTest < ApplicationSystemTestCase
  test "visiting FAQ page shows all categories" do
    visit faq_path

    assert_selector "h1", text: "Frequently Asked Questions"
    assert_selector ".collapse", count: 10 # 10 categories
  end

  test "accordion opens and closes categories" do
    visit faq_path

    # First category should be open by default
    within "#about-products" do
      # DaisyUI accordion uses radio inputs
      assert_selector 'input[type="radio"]:checked'
    end

    # Click another category to open it
    within "#custom-printing" do
      find('input[type="radio"]').click
      assert_selector 'input[type="radio"]:checked'
    end
  end

  test "search finds relevant questions" do
    visit faq_path

    fill_in "q", with: "branded"

    # Wait for debounced search
    sleep 0.5

    assert_text "Search Results"
    assert_selector ".card", minimum: 1
  end

  test "quick links navigate to categories" do
    visit faq_path

    within ".bg-base-200" do
      click_link "Custom Printing & Branding"
    end

    # Should scroll to category (check URL hash)
    assert_equal "custom-printing", URI.parse(current_url).fragment
  end

  test "contact CTA appears in each category" do
    visit faq_path

    # Open a category
    within "#ordering-delivery" do
      find('input[type="radio"]').click
      assert_text "Still have questions"
      assert_link "info@afida.com"
      assert_link "0203 302 7719"
    end
  end
end
