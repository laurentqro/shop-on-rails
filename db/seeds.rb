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

# Create categories
straws_category = Category.find_or_create_by!(
  name: "Straws",
  slug: "straws",
  description: categories_metadata.dig('straws', :meta_description) || "Straws for all your drinks.",
  meta_title: categories_metadata.dig('straws', :meta_title) || "Straws",
  meta_description: categories_metadata.dig('straws', :meta_description) || "Straws for all your drinks."
)

napkins_category = Category.find_or_create_by!(
  name: "Napkins",
  slug: "napkins",
  description: categories_metadata.dig('napkins', :meta_description) || "Napkins for all your drinks.",
  meta_title: categories_metadata.dig('napkins', :meta_title) || "Napkins",
  meta_description: categories_metadata.dig('napkins', :meta_description) || "Napkins for all your drinks."
)

hot_cups_category = Category.find_or_create_by!(
  name: "Hot Cups",
  slug: "hot-cups",
  description: categories_metadata.dig('hot-cups', :meta_description) || "Hot cups for all your drinks.",
  meta_title: categories_metadata.dig('hot-cups', :meta_title) || "Hot Cups",
  meta_description: categories_metadata.dig('hot-cups', :meta_description) || "Hot cups for all your drinks."
)

hot_cups_extras_category = Category.find_or_create_by!(
  name: "Hot Cups Extras",
  slug: "hot-cups-extras",
  description: categories_metadata.dig('hot-cup-extras', :meta_description) || "Hot cups extras for all your drinks.",
  meta_title: categories_metadata.dig('hot-cup-extras', :meta_title) || "Hot Cups Extras",
  meta_description: categories_metadata.dig('hot-cup-extras', :meta_description) || "Hot cups extras for all your drinks."
)

cold_cups_category = Category.find_or_create_by!(
  name: "Cold Cups & Lids",
  slug: "cold-cups-and-lids",
  description: categories_metadata.dig('cold-cups-lids', :meta_description) || "Cold cups and lids for all your drinks.",
  meta_title: categories_metadata.dig('cold-cups-lids', :meta_title) || "Cold Cups & Lids",
  meta_description: categories_metadata.dig('cold-cups-lids', :meta_description) || "Cold cups and lids for all your drinks."
)

pizza_boxes_category = Category.find_or_create_by!(
  name: "Pizza Boxes",
  slug: "pizza-boxes",
  description: categories_metadata.dig('pizza-boxes', :meta_description) || "Pizza boxes for all your drinks.",
  meta_title: categories_metadata.dig('pizza-boxes', :meta_title) || "Pizza Boxes",
  meta_description: categories_metadata.dig('pizza-boxes', :meta_description) || "Pizza boxes for all your drinks."
)

kraft_food_containers_category = Category.find_or_create_by!(
  name: "Kraft Food Containers",
  slug: "kraft-food-containers",
  description: categories_metadata.dig('takeaway-containers', :meta_description) || "Kraft food containers for all your drinks.",
  meta_title: categories_metadata.dig('takeaway-containers', :meta_title) || "Kraft Food Containers",
  meta_description: categories_metadata.dig('takeaway-containers', :meta_description) || "Kraft food containers for all your drinks."
)

ice_cream_cups_category = Category.find_or_create_by!(
  name: "Ice Cream Cups",
  slug: "ice-cream-cups",
  description: categories_metadata.dig('ice-cream-cups', :meta_description) || "Ice cream cups for all your drinks.",
  meta_title: categories_metadata.dig('ice-cream-cups', :meta_title) || "Ice Cream Cups",
  meta_description: categories_metadata.dig('ice-cream-cups', :meta_description) || "Ice cream cups for all your drinks."
)

takeaway_extras_category = Category.find_or_create_by!(
  name: "Takeaway Extras",
  slug: "takeaway-extras",
  description: categories_metadata.dig('takeaway-extras', :meta_description) || "Takeaway extras for all your drinks.",
  meta_title: categories_metadata.dig('takeaway-extras', :meta_title) || "Takeaway Extras",
  meta_description: categories_metadata.dig('takeaway-extras', :meta_description) || "Takeaway extras for all your drinks."
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

# Seed all product categories
product_files = [
  { file: 'straws.yml', category: straws_category },
  { file: 'napkins.yml', category: napkins_category },
  { file: 'hot_cups.yml', category: hot_cups_category },
  { file: 'hot_cups_extras.yml', category: hot_cups_extras_category },
  { file: 'cold_cups.yml', category: cold_cups_category },
  { file: 'pizza_boxes.yml', category: pizza_boxes_category },
  { file: 'kraft_food_containers.yml', category: kraft_food_containers_category },
  { file: 'takeaway_extras.yml', category: takeaway_extras_category },
  { file: 'ice_cream_cups.yml', category: ice_cream_cups_category }
]

product_files.each do |config|
  file_path = Rails.root.join("lib", "data", "products", config[:file])

  if File.exist?(file_path)
    seed_products_from_yaml(file_path, config[:category])
  else
    puts "Warning: File not found: #{file_path}"
  end
end

puts "Seeding completed!"
puts "Categories created: #{Category.count}"
puts "Products created: #{Product.count}"
puts "Product variants created: #{ProductVariant.count}" if defined?(ProductVariant)
