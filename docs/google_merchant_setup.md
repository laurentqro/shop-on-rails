# Google Merchant Center Setup Guide

This guide explains how to set up your products for Google Shopping using our product variant system.

## Product Feed URL

Your Google Merchant product feed is available at:
```
https://yourdomain.com/feeds/google-merchant.xml
```

## How Our Variants Map to Google Shopping

### Product Structure
- **Colors are separate products** - Each color has its own `item_group_id`
- **Sizes/volumes are variants** - Share the same `item_group_id`

### Example Mapping

```
Pizza Boxes (Kraft):
- Product: "Pizza Box - Kraft"
  - item_group_id: "PIZB-KRAFT"
  - Variants: 14", 12", 10", 9", 7"

Hot Cups (by color):
- Product 1: "Double Wall Ripple Paper Hot Cup - Black"
  - item_group_id: "BRDW-CUPS"
  - Variants: 4oz, 8oz, 12oz, 16oz

- Product 2: "Double Wall Ripple Paper Hot Cup - White"  
  - item_group_id: "WRDW-CUPS"
  - Variants: 8oz, 12oz, 16oz
```

## Setting Up Google Merchant Center

1. **Create Account**: Sign up at [merchants.google.com](https://merchants.google.com)

2. **Verify Website**: Follow Google's verification process

3. **Add Product Feed**:
   - Go to Products > Feeds
   - Click the + button
   - Select your country and language
   - Choose "Scheduled fetch"
   - Enter your feed URL: `https://yourdomain.com/feeds/google-merchant.xml`
   - Set fetch schedule (daily recommended)

4. **Configure Shipping**:
   - Go to Tools > Merchant Center programs
   - Set up shipping rates for your regions

5. **Configure Tax** (US only):
   - Set up tax rates if selling in the US

## Feed Validation

After uploading, check for:
- ✅ All variants have unique `id` values (SKUs)
- ✅ Variants of same product share `item_group_id`
- ✅ Each variant has required fields (title, price, availability)
- ✅ Images are accessible and high quality

## Customization

To customize the feed, edit `app/services/google_merchant_feed_generator.rb`:

- Add brand name
- Configure shipping costs
- Add GTIN/EAN codes if available
- Customize product titles

## Best Practices

1. **Keep SKUs Stable**: Don't change SKUs once products are live
2. **Update Regularly**: Schedule daily feed updates
3. **Monitor Errors**: Check Merchant Center diagnostics weekly
4. **Optimize Titles**: Include key attributes (size, color, pack size)
5. **Use High-Quality Images**: At least 800x800px, white background

## Troubleshooting

Common issues:
- **Missing item_group_id**: Only products with multiple variants need this
- **Invalid prices**: Ensure prices include currency (e.g., "45.99 GBP")
- **Image errors**: Check image URLs are publicly accessible
- **Variant mismatch**: Ensure landing page shows selected variant 