namespace :feeds do
  desc "Test Google Merchant feed generation"
  task test_google: :environment do
    puts "Generating Google Merchant feed..."

    products = Product.includes(:category, :active_variants).limit(5)
    generator = GoogleMerchantFeedGenerator.new(products)

    xml = generator.generate_xml

    # Save to file for inspection
    File.write(Rails.root.join("tmp", "google_merchant_test.xml"), xml)

    puts "Feed generated! Check tmp/google_merchant_test.xml"
    puts "\nSample product variants:"

    products.each do |product|
      puts "\n#{product.name} (#{product.colour})"
      product.active_variants.each do |variant|
        puts "  - #{variant.sku}: #{variant.name} @ £#{variant.price}"
      end
    end
  end
end
