# frozen_string_literal: true

require "test_helper"

class FaqHelperTest < ActionView::TestCase
  test "generates valid FAQ schema markup" do
    categories = FaqService.all_categories
    schema_html = faq_schema_markup(categories)

    assert_includes schema_html, "application/ld+json"
    assert_includes schema_html, "FAQPage"
    assert_includes schema_html, "Question"
  end

  test "includes all questions in schema" do
    categories = FaqService.all_categories
    schema_html = faq_schema_markup(categories)

    # Count questions in YAML
    total_questions = categories.sum { |cat| cat["questions"].size }

    # Count Question types in schema
    question_count = schema_html.scan(/"@type":"Question"/).size

    assert_equal total_questions, question_count
  end
end
