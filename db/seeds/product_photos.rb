# Attach product photos to variants based on SKU
puts 'Attaching product photos to variants...'

photo_dir = Rails.root.join('lib', 'data', 'products', 'photos', 'raw')

unless Dir.exist?(photo_dir)
  puts "  ⚠ product_photos directory not found at #{photo_dir}"
  return
end

# Get all photo files
photo_files = Dir.glob(photo_dir.join('*.{webp,png,jpg,jpeg}'))

if photo_files.empty?
  puts "  ⚠ No photo files found in #{photo_dir}"
  return
end

puts "  Found #{photo_files.count} photo files"

attached_count = 0
not_found_count = 0
skipped_count = 0

photo_files.each do |photo_path|
  # Extract SKU from filename (e.g., "14PIZBKR.webp" -> "14PIZBKR")
  filename = File.basename(photo_path)
  sku = File.basename(filename, File.extname(filename))

  # Find variant by SKU
  variant = ProductVariant.find_by(sku: sku)

  unless variant
    not_found_count += 1
    puts "  ⚠ No variant found for SKU: #{sku}"
    next
  end

  # Check if photo is already attached to both product and variant
  if variant.product.product_photo.attached? && variant.product_photo.attached?
    skipped_count += 1
    next
  end

  content_type = case File.extname(filename).downcase
  when '.webp' then 'image/webp'
  when '.png' then 'image/png'
  when '.jpg', '.jpeg' then 'image/jpeg'
  else 'application/octet-stream'
  end

  # Attach photo to the product
  unless variant.product.product_photo.attached?
    variant.product.product_photo.attach(
      io: File.open(photo_path),
      filename: filename,
      content_type: content_type
    )
  end

  # Attach photo to the variant
  unless variant.product_photo.attached?
    variant.product_photo.attach(
      io: File.open(photo_path),
      filename: filename,
      content_type: content_type
    )
  end

  attached_count += 1
  puts "  ✓ Attached #{filename} to #{variant.product.name} (product) and #{variant.sku} (variant)"
end

puts ''
puts 'Product photos attached successfully!'
puts "  Photos attached: #{attached_count}"
puts "  Photos skipped (already attached): #{skipped_count}"
puts "  SKUs not found: #{not_found_count}"
puts "  Products with photos: #{Product.joins(:product_photo_attachment).distinct.count}"
puts "  Variants with photos: #{ProductVariant.joins(:product_photo_attachment).distinct.count}"
