# Create test organization and branded product instance
puts 'Creating test organization data...'

# Create test organization
org = Organization.find_or_create_by!(billing_email: 'test@acmecoffee.com') do |o|
  o.name = 'ACME Coffee'
  o.phone = '+44 20 1234 5678'
end

# Create organization owner
user = User.find_or_create_by!(email_address: 'owner@acmecoffee.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.organization = org
  u.role = 'owner'
end

# Create a customized instance product for ACME
template = Product.find_by(slug: 'double-wall-branded-cups')
if template
  instance = Product.find_or_create_by!(slug: 'acme-12oz-branded-cups') do |p|
    p.name = 'ACME Coffee 12oz Double Wall Branded Cups'
    p.product_type = 'customized_instance'
    p.organization = org
    p.parent_product = template
    p.category = template.category
    p.configuration_data = { size: '12oz', type: 'double_wall', quantity_ordered: 5000 }
    p.description = 'Custom branded cups for ACME Coffee'
    p.active = true
  end

  # Create variant for reordering
  instance.variants.find_or_create_by!(sku: 'BRANDED-ACME-12DW-001') do |v|
    v.name = 'Standard'
    v.price = 0.18
    v.stock_quantity = 5000
    v.active = true
  end

  puts "✓ Created organization: #{org.name}"
  puts "✓ Created owner: #{user.email_address} (password: password123)"
  puts "✓ Created instance product: #{instance.name}"
  puts ''
  puts 'To test customer dashboard:'
  puts '  1. Sign in at http://localhost:3000/signin'
  puts '     Email: owner@acmecoffee.com'
  puts '     Password: password123'
  puts '  2. Visit: http://localhost:3000/organizations/products'
else
  puts '⚠ Template product not found. Run db:seed first.'
end
