# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create categories
straws_category = Category.find_or_create_by!(name: "Straws")
napkins_category = Category.find_or_create_by!(name: "Napkins")
hot_cups_category = Category.find_or_create_by!(name: "Hot Cups")
hot_cups_extras_category = Category.find_or_create_by!(name: "Hot Cups Extras")
cold_cups_category = Category.find_or_create_by!(name: "Cold Cups & Lids")
pizza_boxes_category = Category.find_or_create_by!(name: "Pizza Boxes")
kraft_food_containers_category = Category.find_or_create_by!(name: "Kraft Food Containers")
takeaway_extras_category = Category.find_or_create_by!(name: "Takeaway Extras")
ice_cream_cups_category = Category.find_or_create_by!(name: "Ice Cream Cups")

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
