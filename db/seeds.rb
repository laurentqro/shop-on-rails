# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

straws_category = Category.find_or_create_by!(name: "Straws")
napkins_category = Category.find_or_create_by!(name: "Napkins")
hot_cups_category = Category.find_or_create_by!(name: "Hot Cups")
hot_cups_extras_category = Category.find_or_create_by!(name: "Hot Cups Extras")
cold_cups_category = Category.find_or_create_by!(name: "Cold Cups & Lids")
pizza_boxes_category = Category.find_or_create_by!(name: "Pizza Boxes")
kraft_food_containers_category = Category.find_or_create_by!(name: "Kraft Food Containers")
takeaway_extras_category = Category.find_or_create_by!(name: "Takeaway Extras")
ice_cream_cups_category = Category.find_or_create_by!(name: "Ice Cream Cups")

straws = YAML.load_file(Rails.root.join("lib", "data", "straws.yml"))

straws.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = straws_category
  p.save!
end

napkins = YAML.load_file(Rails.root.join("lib", "data", "napkins.yml"))

napkins.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = napkins_category
  p.save!
end

hot_cups = YAML.load_file(Rails.root.join("lib", "data", "hot_cups.yml"))

hot_cups.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = hot_cups_category
  p.save!
end

hot_cups_extras = YAML.load_file(Rails.root.join("lib", "data", "hot_cups_extras.yml"))

hot_cups_extras.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = hot_cups_extras_category
  p.save!
end

cold_cups = YAML.load_file(Rails.root.join("lib", "data", "cold_cups.yml"))

cold_cups.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = cold_cups_category
  p.save!
end

pizza_boxes = YAML.load_file(Rails.root.join("lib", "data", "pizza_boxes.yml"))

pizza_boxes.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = pizza_boxes_category
  p.save!
end

kraft_food_containers = YAML.load_file(Rails.root.join("lib", "data", "kraft_food_containers.yml"))

kraft_food_containers.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = kraft_food_containers_category
  p.save!
end

takeaway_extras = YAML.load_file(Rails.root.join("lib", "data", "takeaway_extras.yml"))

takeaway_extras.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = takeaway_extras_category
  p.save!
end

ice_cream_cups = YAML.load_file(Rails.root.join("lib", "data", "ice_cream_cups.yml"))

ice_cream_cups.each do |product|
  p = Product.find_or_initialize_by(product)
  p.category = ice_cream_cups_category
  p.save!
end
