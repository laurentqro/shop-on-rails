# frozen_string_literal: true

class FaqService
  class << self
    def all_categories
      @all_categories ||= load_faqs["categories"]
    end

    def find_category(category_id)
      all_categories.find { |cat| cat["id"] == category_id }
    end

    def search(query)
      return [] if query.blank?

      query = query.downcase
      results = []

      all_categories.each do |category|
        category["questions"].each do |question|
          if question["question"].downcase.include?(query) ||
             question["answer"].downcase.include?(query)
            results << {
              category_title: category["title"],
              category_id: category["id"],
              question: question["question"],
              answer: question["answer"],
              question_id: question["id"]
            }
          end
        end
      end

      results
    end

    def reload!
      @all_categories = nil
    end

    private

    def load_faqs
      YAML.load_file(Rails.root.join("config/faqs.yml"))
    end
  end
end
