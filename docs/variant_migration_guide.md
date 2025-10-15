# Product Variant Migration Guide

This guide walks you through migrating your existing products to use the new variant system.

## Overview

The variant system allows products to have multiple options (sizes, volumes, pack sizes) while keeping colors as separate products. This aligns with Google Shopping requirements and provides a better customer experience.

## Migration Steps

### Step 1: Run the Initial Migrations

First, create the necessary database tables and fields:

```bash
# Run all migrations except the one that removes fields
rails db:migrate

# Skip the RemoveVariantFieldsFromProducts migration for now
rails db:migrate:down VERSION=20250115_remove_variant_fields_from_products
```

### Step 2: Run the Data Migration

Execute the rake task to migrate your existing products:

```bash
rails products:migrate_to_variants
```

This will:
- Group products by base name and color
- Create variants for different sizes/volumes
- Merge products that are variants of each other
- Migrate existing cart and order items

Expected output:
```
Starting product variant migration...

Creating single variant for: 8 Fold White 3 Ply Dinner Napkins
  ✓ Created variant: 8FDINWH

Merging 5 products into variants of: Pizza Box - Kraft
  ✓ Created variant: 14 inch (14PIZBKR)
  ✓ Created variant: 12 inch (12PIZBKR)
  ✓ Created variant: 10 inch (10PIZBKR)
  ✓ Created variant: 9 inch (9PIZBKR)
  ✓ Created variant: 7 inch (7PIZBKR)

==================================================
Migration Complete!
==================================================
Products processed: 67
Variants created: 67
Products merged: 25
Cart items migrated: 0
Order items migrated: 0
```

### Step 3: Verify the Migration

Check that the migration completed successfully:

```bash
rails products:verify_variants
```

This shows:
- How many products have variants
- Any products without variants
- Sample variant groups

### Step 4: Remove Old Fields (Optional)

Once you're satisfied with the migration, remove the old fields from the products table:

```bash
rails db:migrate:up VERSION=20250115_remove_variant_fields_from_products
```

⚠️ **Warning**: Only do this after confirming the migration was successful!

## How Products Are Grouped

The migration uses these rules to group products:

### 1. **By Base Name + Color + Category**

Products are grouped when they have:
- Same base name (after removing size indicators)
- Same color
- Same category

Example:
```
"14" / 360 x 360mm Pizza Box - Kraft" → Base: "Pizza Box", Color: "Kraft"
"12" / 310 x 310mm Pizza Box - Kraft" → Base: "Pizza Box", Color: "Kraft"
→ These become variants of "Pizza Box (Kraft)"
```

### 2. **Size/Volume Extraction**

The migration recognizes these patterns:
- Inches: `14"`, `12 inch`
- Volume: `8oz`, `750ml`
- Dimensions: `360x360mm`
- Pack sizes: `Pack of 250`

### 3. **Color = Separate Products**

Different colors create different products:
```
"4 Fold Black 2 Ply Dinner Napkins" → Product 1
"4 Fold White 2 Ply Dinner Napkins" → Product 2 (not a variant)
```

## Troubleshooting

### If Migration Fails

1. Check the error messages in the output
2. Fix any data issues (duplicate SKUs, missing categories, etc.)
3. Rollback if needed: `rails products:rollback_variants`
4. Re-run the migration

### Common Issues

**"product_variants table doesn't exist"**
- Run `rails db:migrate` first

**"Failed to create variant: SKU has already been taken"**
- You have duplicate SKUs in your data
- Clean up duplicates before migrating

**Products not grouping correctly**
- Check that product names follow expected patterns
- Ensure categories are set correctly
- Review the `extract_base_info` method in the rake task

## Manual Adjustments

After migration, you may want to:

1. **Adjust variant names**: 
   ```ruby
   variant = ProductVariant.find_by(sku: '14PIZBKR')
   variant.update!(name: '14" (360mm)')
   ```

2. **Reorder variants**:
   ```ruby
   product.product_variants.find_by(sku: '7PIZBKR').update!(position: 1)
   product.product_variants.find_by(sku: '9PIZBKR').update!(position: 2)
   # etc.
   ```

3. **Add missing variants**:
   ```ruby
   product = Product.find_by(name: 'Pizza Box')
   product.product_variants.create!(
     sku: '16PIZBKR',
     name: '16 inch',
     price: 32.99,
     position: 6
   )
   ```

## Next Steps

After successful migration:

1. Update your product import scripts to create variants
2. Test the product pages to ensure variants display correctly
3. Verify Google Merchant feed shows variants properly
4. Update any reporting to account for the new structure

## Data Model Reference

### Before Migration
```
Product
├── sku: "14PIZBKR"
├── name: "14" Pizza Box - Kraft"
├── price: 28.29
├── colour: "Kraft"
└── dimensions...
```

### After Migration
```
Product
├── name: "Pizza Box"
├── colour: "Kraft"
├── base_sku: "PIZB"
└── variants/
    ├── ProductVariant
    │   ├── sku: "14PIZBKR"
    │   ├── name: "14 inch"
    │   └── price: 28.29
    ├── ProductVariant
    │   ├── sku: "12PIZBKR"
    │   ├── name: "12 inch"
    │   └── price: 22.83
    └── ...
``` 