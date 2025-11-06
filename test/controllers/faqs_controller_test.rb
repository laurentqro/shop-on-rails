# frozen_string_literal: true

require "test_helper"

class FaqsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get faq_url
    assert_response :success
  end

  test "index loads all categories" do
    get faq_url
    assert_response :success
    assert_select "h1", text: "Frequently Asked Questions"
    # Verify we see multiple category cards
    assert_select ".card", minimum: 10
  end

  test "index performs search when query present" do
    get faq_url, params: { q: "branded" }
    assert_response :success
    assert_select "h2", text: /Search Results/
  end

  test "index accessible without authentication" do
    get faq_url
    assert_response :success
  end

  test "search query is displayed in results" do
    get faq_url, params: { q: "shipping" }
    assert_response :success
    assert_select "h2", text: /Search Results for "shipping"/
  end
end
