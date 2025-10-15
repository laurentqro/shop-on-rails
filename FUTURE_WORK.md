# Future Work & Planned Features

This document tracks features and improvements that are planned for future implementation but are not currently in active development.

**Last Updated:** 2025-10-15

---

## Stock Tracking & Inventory Management

### Overview
Implement comprehensive stock tracking system to prevent overselling and manage inventory levels.

### Current State
- `stock_quantity` field exists in `product_variants` table but is not enforced
- `in_stock?` method always returns `true`
- No stock decrement on order creation
- Can oversell products

### Planned Implementation

#### 1. ProductVariant Model Changes
Add stock management methods:

```ruby
# Check if variant is in stock
def in_stock?
  stock_quantity > 0
end

# Check if requested quantity is available
def available?(quantity)
  stock_quantity >= quantity
end

# Decrement stock with race condition protection
def decrement_stock!(quantity)
  raise ArgumentError, "Quantity must be positive" if quantity <= 0

  # Use UPDATE with WHERE clause to prevent overselling
  updated = self.class.where(id: id)
                      .where("stock_quantity >= ?", quantity)
                      .update_all("stock_quantity = stock_quantity - #{quantity.to_i}")

  if updated > 0
    reload
    true
  else
    errors.add(:stock_quantity, "insufficient stock (available: #{stock_quantity})")
    false
  end
end

# Check if stock is low
def low_stock?(threshold = 10)
  stock_quantity > 0 && stock_quantity <= threshold
end
```

Add scopes:
```ruby
scope :in_stock, -> { where("stock_quantity > 0") }
scope :low_stock, ->(threshold = 10) { where("stock_quantity > 0 AND stock_quantity <= ?", threshold) }
scope :out_of_stock, -> { where(stock_quantity: 0) }
```

#### 2. CartItem Validations
Add stock validations when adding items to cart:

```ruby
validate :variant_must_be_in_stock
validate :quantity_must_be_available

private

def variant_must_be_in_stock
  return unless product_variant

  unless product_variant.in_stock?
    errors.add(:product_variant, "is out of stock")
  end
end

def quantity_must_be_available
  return unless product_variant && quantity

  unless product_variant.available?(quantity)
    errors.add(:quantity, "exceeds available stock (#{product_variant.stock_quantity} available)")
  end
end
```

#### 3. Order Creation Changes
Decrement stock when orders are created in `CheckoutsController#create_order_from_stripe_session`:

```ruby
cart.cart_items.each do |cart_item|
  # Decrement stock for this variant
  unless cart_item.product_variant.decrement_stock!(cart_item.quantity)
    # If stock decrement fails, rollback the order
    order.destroy
    raise "Insufficient stock for #{cart_item.product_variant.display_name}"
  end

  order.order_items.create!(
    # ... existing code
  )
end
```

#### 4. Admin Interface
- Show current stock levels in admin product list
- Add low stock warnings (< 10 units)
- Add out of stock indicators
- Allow manual stock adjustments with audit trail
- Bulk stock import/export

#### 5. Customer-Facing Features
- Show "In Stock" / "Out of Stock" badges on product pages
- Show "Only X left!" messages for low stock items
- Prevent adding out-of-stock items to cart
- Show available quantity on product detail page
- Update cart if item goes out of stock

#### 6. Background Jobs
Create jobs for:
- Stock level monitoring and alerts
- Automatic out-of-stock email to admins
- Low stock notifications
- Stock reconciliation reports

#### 7. Stock Restoration
Handle order cancellations and refunds:
```ruby
# In Order model or service
def restore_stock!
  order_items.each do |item|
    item.product_variant.increment!(:stock_quantity, item.quantity)
  end
end
```

### Race Condition Considerations
- Use database-level UPDATE with WHERE clause
- Prevents overselling with concurrent orders
- Transaction-safe operations
- Optimistic locking for admin updates

### Testing Requirements
- Test concurrent order creation
- Test stock decrement edge cases
- Test validation error messages
- Test stock restoration on cancellation
- Load testing for high-volume scenarios

### Deployment Considerations
- Set initial stock levels for all existing products
- Decide on backorder vs. prevent-order strategy
- Consider integration with warehouse management system
- Plan for multi-location inventory (future)

### Estimated Effort
**5-7 days** including:
- Model changes: 1 day
- Controller updates: 1 day
- Admin interface: 2 days
- Testing: 1-2 days
- Documentation: 1 day

### Priority
**HIGH** - Critical for preventing customer complaints and revenue loss from overselling

---

## Order Status Workflow Management

### Overview
Implement proper order lifecycle management with status transitions and notifications.

### Current State
- Order status enum exists but no workflow
- Orders stay in "paid" status indefinitely
- No status change tracking
- No customer notifications for status changes

### Planned Implementation

#### 1. Add State Machine
Use AASM or Statesman gem for order workflow:

```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :paid
    state :processing
    state :shipped
    state :delivered
    state :cancelled
    state :refunded

    event :mark_as_paid do
      transitions from: :pending, to: :paid
    end

    event :start_processing do
      transitions from: :paid, to: :processing
    end

    event :mark_as_shipped do
      transitions from: :processing, to: :shipped
      after do
        OrderMailer.shipped_notification(self).deliver_later
      end
    end

    event :mark_as_delivered do
      transitions from: :shipped, to: :delivered
    end

    event :cancel do
      transitions from: [:pending, :paid, :processing], to: :cancelled
      after do
        restore_stock!
        OrderMailer.cancellation_notification(self).deliver_later
      end
    end

    event :refund do
      transitions from: [:paid, :processing, :shipped, :delivered], to: :refunded
      after do
        restore_stock!
        # Process Stripe refund
      end
    end
  end
end
```

#### 2. Admin Interface
- Add status change buttons in admin order view
- Show status history timeline
- Add notes/comments for status changes
- Tracking number input for shipped status

#### 3. Customer Notifications
Email templates for:
- Order confirmed (paid)
- Order processing
- Order shipped (with tracking)
- Order delivered
- Order cancelled
- Refund processed

#### 4. Status History Tracking
Create `OrderStatusChanges` table:
```ruby
create_table :order_status_changes do |t|
  t.belongs_to :order, null: false
  t.string :from_status, null: false
  t.string :to_status, null: false
  t.belongs_to :user # Admin who made the change
  t.text :notes
  t.timestamps
end
```

### Estimated Effort
**3-5 days**

### Priority
**HIGH** - Essential for customer service and operations

---

## Price Change Tracking & History

### Overview
Track price changes over time and alert customers to changes.

### Implementation Ideas
- `PriceHistory` model
- Alert when variant price changes after adding to cart
- Show price change warnings at checkout
- Admin price change audit trail

### Priority
**MEDIUM**

---

## Multi-Currency Support

### Overview
Support multiple currencies for international expansion.

### Considerations
- Currency selection by country
- Exchange rate updates
- Stripe multi-currency support
- Price display in local currency

### Priority
**LOW** (Future expansion)

---

## Advanced Search & Filtering

### Overview
Full-text search with filters for better product discovery.

### Implementation Ideas
- PgSearch for PostgreSQL full-text search
- Filter by category, price range, attributes
- Sort by price, popularity, newest
- Search suggestions/autocomplete

### Estimated Effort
**4-6 days**

### Priority
**MEDIUM**

---

## Product Reviews & Ratings

### Overview
Allow customers to review and rate products.

### Features
- Star ratings (1-5)
- Written reviews
- Review moderation
- Verified purchase badge
- Average rating display
- Sort/filter by rating

### Estimated Effort
**5-7 days**

### Priority
**LOW**

---

## Wishlist / Saved Items

### Overview
Allow users to save products for later.

### Features
- Add to wishlist from product page
- Wishlist page
- Move from wishlist to cart
- Email notifications for price drops
- Share wishlist with others

### Estimated Effort
**3-4 days**

### Priority
**LOW**

---

## Discount Codes & Promotions

### Overview
Support coupon codes and promotional pricing.

### Features
- Percentage or fixed amount discounts
- Minimum order requirements
- Product/category restrictions
- Expiration dates
- Usage limits
- Automatic promotions (buy X get Y)

### Estimated Effort
**7-10 days**

### Priority
**MEDIUM**

---

## Abandoned Cart Recovery

### Overview
Email customers who abandon their carts.

### Features
- Background job to detect abandoned carts (1 hour, 24 hours)
- Email reminders with cart contents
- Discount codes to encourage completion
- Analytics on recovery rate

### Estimated Effort
**3-4 days**

### Priority
**MEDIUM**

---

## Analytics Dashboard

### Overview
Admin dashboard with sales metrics and insights.

### Features
- Daily/weekly/monthly sales charts
- Top selling products
- Revenue by category
- Customer acquisition metrics
- Conversion funnel
- Stock level alerts

### Integration Options
- Built-in with Chartkick
- Google Analytics
- Mixpanel
- Custom solution

### Estimated Effort
**5-7 days**

### Priority
**MEDIUM**

---

## Multi-Warehouse Support

### Overview
Support inventory across multiple locations.

### Features
- Warehouse management
- Stock allocation by location
- Shipping from nearest warehouse
- Transfer between warehouses
- Location-based availability

### Estimated Effort
**10-15 days**

### Priority
**LOW** (Future expansion)

---

## Subscription Products

### Overview
Support recurring subscription orders.

### Features
- Subscription plans (weekly, monthly, etc.)
- Stripe subscription integration
- Manage/pause/cancel subscriptions
- Subscription billing management

### Estimated Effort
**7-10 days**

### Priority
**LOW**

---

## Customer Support Features

### Overview
Built-in customer support tools.

### Features
- Order tracking page
- Return request system
- Support ticket system
- Live chat integration
- FAQ/Help center

### Estimated Effort
**10-14 days**

### Priority
**MEDIUM**

---

## Next Steps

1. Review and prioritize this list quarterly
2. Move items to TECH_DEBT.md when ready for active development
3. Break down large items into smaller tasks
4. Estimate and schedule based on business priorities

---

**Document Version:** 1.0
**Next Review:** 2026-01-15
