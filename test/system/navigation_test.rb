# frozen_string_literal: true

require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  test "FAQ link in footer navigates to FAQ page" do
    visit root_path

    within "footer", match: :first do
      click_link "FAQs"
    end

    assert_current_path faq_path
    assert_selector "h1", text: "Frequently Asked Questions"
  end
end
