# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

puts "Loading categories metadata from CSV..."
categories_metadata = {}
CSV.foreach(Rails.root.join('lib', 'data', 'categories.csv'), headers: true) do |row|
  data = row.to_h
  slug = data['slug']&.strip
  if slug
    categories_metadata[slug] = {
      name: data['name']&.strip&.gsub(/\s+/, ' '),
      meta_title: data['meta_title']&.strip,
      meta_description: data['meta_description']&.strip&.gsub(/\s+/, ' ')
    }
  end
end
puts "Categories metadata loaded."

# Create BrandYour-style categories
drinks_category = Category.find_or_create_by!(
  name: "Drinks",
  slug: "drinks",
  description: "Cups and straws for all your beverages - hot and cold",
  meta_title: "Drinks Packaging - Cups & Straws | Afida",
  meta_description: "Eco-friendly cups and straws for hot and cold drinks. Sustainable beverage packaging."
)

mains_category = Category.find_or_create_by!(
  name: "Mains",
  slug: "mains",
  description: "Food packaging for main courses - pizza boxes, containers",
  meta_title: "Food Packaging - Boxes & Containers | Afida",
  meta_description: "Eco-friendly food packaging for pizzas, takeaway meals, and more."
)

desserts_category = Category.find_or_create_by!(
  name: "Desserts",
  slug: "desserts",
  description: "Packaging for desserts and sweet treats",
  meta_title: "Dessert Packaging - Ice Cream Cups | Afida",
  meta_description: "Sustainable packaging for ice cream, desserts, and sweet treats."
)

bags_category = Category.find_or_create_by!(
  name: "Bags",
  slug: "bags",
  description: "Takeaway and carrier bags for your orders",
  meta_title: "Takeaway Bags - Kraft & Paper Bags | Afida",
  meta_description: "Eco-friendly takeaway bags and carrier bags for your business."
)

accessories_category = Category.find_or_create_by!(
  name: "Accessories",
  slug: "accessories",
  description: "Lids, napkins, cutlery, and other accessories",
  meta_title: "Accessories - Lids, Napkins & More | Afida",
  meta_description: "Complete your order with lids, napkins, cutlery, and accessories."
)

# Brandable products category (custom printing)
brandable_category = Category.find_or_create_by!(
  name: "Brandable Products",
  slug: "brandable-products",
  description: "Customize these products with your own design and branding",
  meta_title: "Brandable Products - Custom Printing | Afida",
  meta_description: "Create custom branded packaging with your design. Cups, boxes, bags and more."
)

# Helper method to seed products from YAML files
def seed_products_from_yaml(file_path, category)
  puts "Seeding products from #{file_path}..."

  yaml_data = YAML.load_file(file_path)
  products_data = yaml_data['products'] || []

  products_data.each do |product_data|
    # Extract product attributes (everything except variants)
    product_attributes = product_data.except('variants')

    # Find or create the product
    product = Product.find_or_initialize_by(name: product_attributes['name'])

    # Update product attributes
    product.assign_attributes(product_attributes)
    product.category = category
    product.save!
    puts "  Created/Updated product: #{product.name}"
    # Handle variants if they exist
    if product_data['variants']
      product_data['variants'].each do |variant_data|
        # Find or create variant by SKU (assuming SKU is unique)
        if variant_data['sku']
          variant = ProductVariant.find_or_initialize_by(sku: variant_data['sku'])
          variant.assign_attributes(variant_data)
          variant.product = product
          variant.save!

          puts "Created/Updated variant: #{variant.name} (#{variant.sku})"
        else
          puts "Warning: Variant missing SKU: #{variant_data}"
        end
      end
    end
  end
end

# Load product options first (required for products with options)
load Rails.root.join('db', 'seeds', 'product_options.rb')

# Load products from consolidated CSV (replaces YAML-based seeding)
load Rails.root.join('db', 'seeds', 'products_from_csv.rb')

# Load branded product pricing seed
load Rails.root.join('db', 'seeds', 'branded_product_pricing.rb')

# Load hot cup lids seed (may be redundant if lids are in CSV)
# load Rails.root.join('db', 'seeds', 'hot_cup_lids.rb')

puts "Seeding completed!"
puts "Categories created: #{Category.count}"
puts "Products created: #{Product.count}"
puts "Product variants created: #{ProductVariant.count}" if defined?(ProductVariant)
puts "Product options created: #{ProductOption.count}" if defined?(ProductOption)
puts "Product option values created: #{ProductOptionValue.count}" if defined?(ProductOptionValue)
puts "Branded product prices created: #{BrandedProductPrice.count}" if defined?(BrandedProductPrice)
