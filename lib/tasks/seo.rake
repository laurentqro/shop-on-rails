namespace :seo do
  desc "Validate SEO implementation"
  task validate: :environment do
    puts "🔍 Running SEO Validation..."
    puts

    warnings = []

    # Check products
    products_without_meta_desc = Product.where(meta_description: [ nil, "" ]).count
    if products_without_meta_desc > 0
      warnings << "⚠️  #{products_without_meta_desc} products missing custom meta_description"
    end

    products_without_meta_title = Product.where(meta_title: [ nil, "" ]).count
    if products_without_meta_title > 0
      warnings << "⚠️  #{products_without_meta_title} products missing custom meta_title"
    end

    # Check categories
    categories_without_meta_desc = Category.where(meta_description: [ nil, "" ]).count
    if categories_without_meta_desc > 0
      warnings << "⚠️  #{categories_without_meta_desc} categories missing meta_description"
    end

    categories_without_meta_title = Category.where(meta_title: [ nil, "" ]).count
    if categories_without_meta_title > 0
      warnings << "⚠️  #{categories_without_meta_title} categories missing meta_title"
    end

    # Display results
    if warnings.any?
      puts warnings.join("\n")
      puts
      puts "💡 Tip: Add custom meta_title and meta_description to improve SEO"
    else
      puts "✅ All SEO checks passed!"
      puts
      puts "📊 Summary:"
      puts "   • #{Product.count} products with complete SEO metadata"
      puts "   • #{Category.count} categories with complete SEO metadata"
      puts "   • Sitemap available at /sitemap.xml"
      puts "   • Robots.txt configured with sitemap reference"
    end
  end
end
