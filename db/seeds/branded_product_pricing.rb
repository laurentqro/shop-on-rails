# Branded Product Pricing (from CSV data)
puts "Creating branded product pricing..."

# Find or create branded product categories
branded_category = Category.find_or_create_by!(name: "Branded Products") do |cat|
  cat.slug = "branded-products"
  cat.description = "Custom branded packaging for your business"
end

# Create Single Wall Branded Cups template
single_wall_branded = Product.find_or_create_by!(slug: "single-wall-branded-cups") do |product|
  product.name = "Single Wall Branded Cups"
  product.product_type = "customizable_template"
  product.category = branded_category
  product.description = "Custom branded single-wall cups with your design. Perfect for coffee shops, cafes, and events."
  product.active = true
  product.sort_order = 1
end

# Pricing from CSV: Single Wall
pricing_data_sw = [
  { size: "8oz", quantity: 1000, price: 0.26, case_qty: 1000 },
  { size: "8oz", quantity: 2000, price: 0.20, case_qty: 1000 },
  { size: "8oz", quantity: 5000, price: 0.15, case_qty: 1000 },
  { size: "8oz", quantity: 10000, price: 0.12, case_qty: 1000 },
  { size: "8oz", quantity: 20000, price: 0.11, case_qty: 1000 },
  { size: "8oz", quantity: 30000, price: 0.10, case_qty: 1000 },

  { size: "12oz", quantity: 1000, price: 0.28, case_qty: 1000 },
  { size: "12oz", quantity: 5000, price: 0.17, case_qty: 1000 },
  { size: "12oz", quantity: 10000, price: 0.14, case_qty: 1000 },
  { size: "12oz", quantity: 20000, price: 0.12, case_qty: 1000 },
  { size: "12oz", quantity: 30000, price: 0.11, case_qty: 1000 },

  { size: "16oz", quantity: 1000, price: 0.30, case_qty: 1000 },
  { size: "16oz", quantity: 5000, price: 0.20, case_qty: 1000 },
  { size: "16oz", quantity: 10000, price: 0.17, case_qty: 1000 },
  { size: "16oz", quantity: 20000, price: 0.15, case_qty: 1000 },
  { size: "16oz", quantity: 30000, price: 0.14, case_qty: 1000 }
]

pricing_data_sw.each do |data|
  single_wall_branded.branded_product_prices.find_or_create_by!(
    size: data[:size],
    quantity_tier: data[:quantity]
  ) do |price|
    price.price_per_unit = data[:price]
    price.case_quantity = data[:case_qty]
  end
end

puts "  Single Wall Branded Cups: #{pricing_data_sw.size} pricing tiers created"

# Create Double Wall Branded Cups template
double_wall_branded = Product.find_or_create_by!(slug: "double-wall-branded-cups") do |product|
  product.name = "Double Wall Branded Cups"
  product.product_type = "customizable_template"
  product.category = branded_category
  product.description = "Premium double-wall insulated cups with your custom branding. No sleeve needed!"
  product.active = true
  product.sort_order = 2
end

# Pricing from CSV: Double Wall
pricing_data_dw = [
  { size: "8oz", quantity: 1000, price: 0.30, case_qty: 500 },
  { size: "8oz", quantity: 2000, price: 0.25, case_qty: 500 },
  { size: "8oz", quantity: 5000, price: 0.18, case_qty: 500 },
  { size: "8oz", quantity: 10000, price: 0.15, case_qty: 500 },
  { size: "8oz", quantity: 20000, price: 0.11, case_qty: 500 },
  { size: "8oz", quantity: 30000, price: 0.10, case_qty: 500 },

  { size: "12oz", quantity: 1000, price: 0.32, case_qty: 500 },
  { size: "12oz", quantity: 5000, price: 0.20, case_qty: 500 },
  { size: "12oz", quantity: 10000, price: 0.17, case_qty: 500 },
  { size: "12oz", quantity: 20000, price: 0.13, case_qty: 500 },
  { size: "12oz", quantity: 30000, price: 0.12, case_qty: 500 },

  { size: "16oz", quantity: 1000, price: 0.34, case_qty: 500 },
  { size: "16oz", quantity: 5000, price: 0.22, case_qty: 500 },
  { size: "16oz", quantity: 10000, price: 0.19, case_qty: 500 },
  { size: "16oz", quantity: 20000, price: 0.15, case_qty: 500 },
  { size: "16oz", quantity: 30000, price: 0.14, case_qty: 500 }
]

pricing_data_dw.each do |data|
  double_wall_branded.branded_product_prices.find_or_create_by!(
    size: data[:size],
    quantity_tier: data[:quantity]
  ) do |price|
    price.price_per_unit = data[:price]
    price.case_quantity = data[:case_qty]
  end
end

puts "  Double Wall Branded Cups: #{pricing_data_dw.size} pricing tiers created"
puts "Branded product pricing created successfully!"
puts "  Total pricing entries: #{pricing_data_sw.size + pricing_data_dw.size}"
