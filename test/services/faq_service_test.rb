# frozen_string_literal: true

require "test_helper"

class FaqServiceTest < ActiveSupport::TestCase
  test "loads all FAQ categories" do
    categories = FaqService.all_categories
    assert_not_empty categories
    assert_equal 10, categories.size
  end

  test "finds category by id" do
    category = FaqService.find_category("about-products")
    assert_not_nil category
    assert_equal "About Our Products", category["title"]
  end

  test "searches questions and answers" do
    results = FaqService.search("branded")
    assert_not_empty results
    assert results.any? { |r| r[:question].include?("branded") }
  end

  test "search is case insensitive" do
    results = FaqService.search("BRANDED")
    assert_not_empty results
  end

  test "returns empty array for blank query" do
    assert_empty FaqService.search("")
    assert_empty FaqService.search(nil)
  end

  test "search returns category context with results" do
    results = FaqService.search("branded")
    first_result = results.first

    assert first_result.key?(:category_title)
    assert first_result.key?(:category_id)
    assert first_result.key?(:question)
    assert first_result.key?(:answer)
    assert first_result.key?(:question_id)
  end
end
