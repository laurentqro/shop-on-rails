# frozen_string_literal: true

module FaqHelper
  def faq_schema_markup(categories)
    schema = {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": []
    }

    categories.each do |category|
      category["questions"].each do |question|
        schema[:mainEntity] << {
          "@type": "Question",
          "name": question["question"],
          "acceptedAnswer": {
            "@type": "Answer",
            "text": question["answer"]
          }
        }
      end
    end

    content_tag(:script, schema.to_json.html_safe, type: "application/ld+json")
  end
end
