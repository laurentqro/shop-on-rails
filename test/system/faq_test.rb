# frozen_string_literal: true

require "application_system_test_case"

class FaqTest < ApplicationSystemTestCase
  test "visiting FAQ page shows all categories" do
    visit faqs_path

    assert_selector "h1", text: "Frequently Asked Questions"
    assert_selector "h2", count: 10 # 10 category headers
    assert_selector ".collapse", count: 33 # 33 question accordions
  end

  test "accordion opens and closes questions" do
    visit faqs_path

    # All questions start closed
    within "#about-products" do
      # DaisyUI accordion uses radio inputs (only one open at a time)
      first_question = first(".collapse")
      radio = first_question.find('input[type="radio"]', visible: false)

      # Open the question
      radio.click
      assert radio.checked?
    end

    # Opening another question should close the first
    within "#custom-printing" do
      first_question = first(".collapse")
      radio = first_question.find('input[type="radio"]', visible: false)
      radio.click
      assert radio.checked?
    end

    # First question should now be closed
    within "#about-products" do
      first_question = first(".collapse")
      radio = first_question.find('input[type="radio"]', visible: false)
      assert_not radio.checked?
    end
  end

  test "search finds relevant questions" do
    visit faqs_path

    fill_in "q", with: "branded"

    # Wait for debounced search
    sleep 0.5

    assert_text "Search Results"
    assert_selector ".card", minimum: 1
  end

  test "quick links navigate to categories" do
    visit faqs_path

    within ".bg-base-200" do
      click_link "Custom Printing & Branding"
    end

    # Should scroll to category (check URL hash)
    assert_equal "custom-printing", URI.parse(current_url).fragment
  end

  test "contact CTA appears at bottom of page" do
    visit faqs_path

    assert_text "Still have questions?"
    assert_link "info@afida.com"
    assert_link "0203 302 7719"
  end
end
