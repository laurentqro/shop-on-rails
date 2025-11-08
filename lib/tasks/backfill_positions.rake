namespace :positions do
  desc "Backfill position values for products and product variants"
  task backfill: :environment do
    puts "Backfilling positions..."

    # Backfill product positions (ordered by ID within each category)
    backfilled_count = 0
    Category.find_each do |category|
      puts "  Category: #{category.name}"
      category.products.unscoped.where(category_id: category.id).order(:id).each_with_index do |product, index|
        if product.position.nil?
          product.update_column(:position, index + 1)
          backfilled_count += 1
          print "."
        end
      end
      puts " (#{category.products.unscoped.where(category_id: category.id).count} products)"
    end

    # Backfill product variant positions if needed
    nil_variants = ProductVariant.where(position: nil).count
    if nil_variants > 0
      puts "\nBackfilling #{nil_variants} product variants..."
      ProductVariant.where(position: nil).find_each do |variant|
        variant.update_column(:position, 1)
        print "."
      end
      puts " Done!"
    end

    puts "\nBackfill complete!"
    puts "  Products backfilled: #{backfilled_count}"
    puts "  Product variants backfilled: #{nil_variants}"
  end

  desc "Check position status"
  task status: :environment do
    puts "Position Status:"
    puts "  Categories with nil position: #{Category.where(position: nil).count}"
    puts "  Products with nil position: #{Product.unscoped.where(position: nil).count}"
    puts "  ProductVariants with nil position: #{ProductVariant.where(position: nil).count}"
  end
end
