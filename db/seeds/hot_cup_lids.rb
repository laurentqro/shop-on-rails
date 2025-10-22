# Hot Cup Lids seed data
puts 'Creating hot cup lids...'

# Find or create Hot Cups Extras category
hot_cups_extras = Category.find_or_create_by!(slug: 'hot-cups-extras') do |cat|
  cat.name = 'Hot Cups Extras'
  cat.description = 'Lids, stirrers, and accessories for hot cups'
end

# Paper Sip Lids
paper_lids = Product.find_or_create_by!(slug: 'paper-sip-lids-for-hot-cups') do |product|
  product.name = 'Paper Sip Lids for Hot Cups'
  product.category = hot_cups_extras
  product.description = 'White recycled paper sip lids for hot cups'
  product.active = true
  product.product_type = 'standard'
end

[
  { sku: 'PAPL80', name: '80mm', size: '80mm', price: 45.00, pac_size: 1000 },
  { sku: 'PAPL90', name: '90mm', size: '90mm', price: 48.00, pac_size: 1000 }
].each do |variant_data|
  paper_lids.variants.find_or_create_by!(sku: variant_data[:sku]) do |v|
    v.name = variant_data[:name]
    v.price = variant_data[:price]
    v.stock_quantity = 10000
    v.pac_size = variant_data[:pac_size]
    v.active = true
  end
end

# Recyclable Sip Lids - Black
recyclable_black_lids = Product.find_or_create_by!(slug: 'recyclable-sip-lids-black') do |product|
  product.name = 'Recyclable Sip Lids for Hot Cups - Black'
  product.category = hot_cups_extras
  product.description = 'Black recyclable sip lids for hot cups'
  product.active = true
  product.product_type = 'standard'
  product.colour = 'Black'
end

[
  { sku: 'PLPC62B', name: '62mm', size: '62mm', price: 42.00, pac_size: 1000 },
  { sku: 'PLPC80B', name: '80mm', size: '80mm', price: 46.00, pac_size: 1000 },
  { sku: 'PLPC90B', name: '90mm', size: '90mm', price: 50.00, pac_size: 1000 }
].each do |variant_data|
  recyclable_black_lids.variants.find_or_create_by!(sku: variant_data[:sku]) do |v|
    v.name = variant_data[:name]
    v.price = variant_data[:price]
    v.stock_quantity = 10000
    v.pac_size = variant_data[:pac_size]
    v.active = true
  end
end

# Recyclable Sip Lids - White
recyclable_white_lids = Product.find_or_create_by!(slug: 'recyclable-sip-lids-white') do |product|
  product.name = 'Recyclable Sip Lids for Hot Cups - White'
  product.category = hot_cups_extras
  product.description = 'White recyclable sip lids for hot cups'
  product.active = true
  product.product_type = 'standard'
  product.colour = 'White'
end

[
  { sku: 'PLPC62W', name: '62mm', size: '62mm', price: 42.00, pac_size: 1000 },
  { sku: 'PLPC80W', name: '80mm', size: '80mm', price: 46.00, pac_size: 1000 },
  { sku: 'PLPC90W', name: '90mm', size: '90mm', price: 50.00, pac_size: 1000 }
].each do |variant_data|
  recyclable_white_lids.variants.find_or_create_by!(sku: variant_data[:sku]) do |v|
    v.name = variant_data[:name]
    v.price = variant_data[:price]
    v.stock_quantity = 10000
    v.pac_size = variant_data[:pac_size]
    v.active = true
  end
end

puts "✓ Created #{Product.where(category: hot_cups_extras).count} lid products"
puts "✓ Created #{ProductVariant.joins(:product).where(products: { category: hot_cups_extras }).count} lid variants"
puts ''
puts 'Hot cup lids available:'
puts '  - 62mm lids (for 4oz cups): Black, White'
puts '  - 80mm lids (for 6oz/8oz cups): Paper White, Black, White'
puts '  - 90mm lids (for 10oz/12oz/16oz/20oz cups): Paper White, Black, White'
