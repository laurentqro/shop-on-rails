# Technical Debt & Improvement Suggestions

## Executive Summary

This document outlines technical debt, improvement opportunities, and potential issues identified in the Rails 8 e-commerce application. Items are prioritized by severity and impact.

**Last Updated:** 2025-10-15

---

## 1. Critical Security Issues

### 1.1 Admin Authentication Vulnerability
**Priority:** CRITICAL
**Location:** `app/controllers/admin/application_controller.rb:8`

**Issue:** The `require_admin` method will raise a `NoMethodError` when `Current.user` is `nil` (unauthenticated users).

```ruby
def require_admin
  redirect_to root_path, alert: "You are not authorized to access this page." unless Current.user.admin?
end
```

**Impact:** Unauthenticated users will see error pages instead of being redirected.

**Recommendation:**
```ruby
def require_admin
  redirect_to root_path, alert: "You are not authorized to access this page." unless Current.user&.admin?
end
```

### 1.2 Stripe Tax Rate Creation on Every Checkout
**Priority:** HIGH
**Location:** `app/controllers/checkouts_controller.rb:198-207`

**Issue:** The `tax_rate` method creates a new Stripe TaxRate object on every checkout request.

**Impact:**
- Creates duplicate tax rates in Stripe
- Potential rate limiting issues
- Unnecessary API calls

**Recommendation:**
- Create tax rate once and store the ID in credentials or environment variables
- Use Stripe's reusable tax rates: `Stripe::TaxRate.list` to find existing rate

### 1.3 Missing Rate Limiting
**Priority:** HIGH

**Issue:** No rate limiting on:
- Cart operations (add/update/delete items)
- Checkout creation
- Registration/login endpoints

**Impact:** Vulnerable to:
- DDoS attacks
- Cart spam
- Brute force attacks

**Recommendation:**
- Add `rack-attack` gem
- Implement rate limiting on sensitive endpoints
- Add CAPTCHA for registration

### 1.4 No CSRF Protection Verification for Stripe Webhooks
**Priority:** MEDIUM

**Issue:** The app handles Stripe checkout via redirect but doesn't implement webhook verification for payment status updates.

**Impact:** If webhooks are added later without proper signature verification, the app could be vulnerable to fake payment confirmations.

**Recommendation:**
- Document webhook implementation requirements
- When implementing webhooks, verify signatures using `Stripe::Webhook.construct_event`

---

## 2. Performance & Scalability

### 2.1 N+1 Query in Cart Display
**Priority:** HIGH
**Location:** `app/models/cart.rb:31-38`

**Issue:** Methods like `items_count`, `subtotal_amount`, and `vat_amount` iterate through `cart_items` without eager loading.

**Impact:** Multiple database queries when displaying cart with many items.

**Recommendation:**
```ruby
# In controllers, eager load associations:
@cart = Current.cart.includes(cart_items: { product_variant: :product })

# Or add counter caches and amount caches to Cart model
```

### 2.2 Missing Database Indexes
**Priority:** MEDIUM
**Location:** `db/schema.rb`

**Missing Indexes:**
- `carts.created_at` (for cleanup of abandoned carts)
- `sessions.created_at` (for session cleanup)
- `products.active` (frequently queried in default scope)
- `products.featured` (for featured products query)
- `product_variants.active` (frequently queried)

**Recommendation:**
```ruby
add_index :carts, :created_at
add_index :sessions, :created_at
add_index :products, :active
add_index :products, :featured
add_index :product_variants, :active
```

### 2.3 Default Scope on ProductVariant
**Priority:** MEDIUM
**Location:** `app/models/product_variant.rb:32`

**Issue:** Default scope `order(:name)` applies to all queries, even when different ordering is needed.

**Impact:**
- Less flexible queries
- Potential performance issues
- Can cause unexpected behavior

**Recommendation:**
- Remove default scope
- Use explicit scopes: `scope :by_name, -> { order(:name) }`
- Use `sort_order` field for default ordering

### 2.4 No Caching Strategy
**Priority:** MEDIUM

**Issue:** No fragment caching or page caching for:
- Product listings
- Category pages
- Product detail pages
- Shopping cart badge counter

**Recommendation:**
```erb
<%# In views %>
<% cache product do %>
  <%= render product %>
<% end %>

<%# Russian doll caching for product lists %>
<% cache ['products-list', Product.maximum(:updated_at)] do %>
  <% @products.each do |product| %>
    <% cache product do %>
      <%= render product %>
    <% end %>
  <% end %>
<% end %>
```

### 2.5 Missing Background Job Processing
**Priority:** MEDIUM
**Location:** `app/controllers/checkouts_controller.rb:116`

**Issue:** Email is sent with `deliver_later` but no evidence of Solid Queue being properly configured.

**Recommendation:**
- Verify Solid Queue is running in production
- Add monitoring for job queue health
- Consider moving order creation to background job for better UX

---

## 3. Code Quality & Maintainability

### 3.1 Product Data Duplication
**Priority:** HIGH
**Location:** Schema - `products` and `product_variants` tables

**Issue:** Physical dimensions (`diameter_in_mm`, `volume_in_ml`, `weight_in_g`, etc.) exist on both `products` and `product_variants` tables.

**Impact:**
- Data inconsistency risk
- Confusion about which values to use
- Maintenance burden

**Recommendation:**
- Decide on single source of truth (variants preferred)
- Remove dimension fields from products table
- Migrate any product-level dimensions to variants

### 3.2 Duplicated VAT_RATE Constant
**Priority:** MEDIUM
**Location:** `app/models/cart.rb:28` and `app/models/cart_item.rb:6`

**Issue:** `VAT_RATE` defined in both Cart and CartItem.

**Recommendation:**
```ruby
# config/initializers/vat.rb
VAT_RATE = 0.2

# Or create a concern/module
module VatCalculations
  VAT_RATE = 0.2
end
```

### 3.3 Hardcoded Business Logic in Controllers
**Priority:** MEDIUM
**Location:** `app/controllers/checkouts_controller.rb:29-58`

**Issue:** Shipping options are hardcoded in controller.

**Recommendation:**
- Move to configuration file or database table
- Create `ShippingOption` model
- Enable dynamic shipping rate management

### 3.4 Long Controller Methods
**Priority:** MEDIUM
**Location:** `app/controllers/checkouts_controller.rb:138-196`

**Issue:** `create_order_from_stripe_session` is 58 lines long.

**Recommendation:**
- Extract to service object: `OrderCreationService`
- Better separation of concerns
- Easier to test

```ruby
# app/services/order_creation_service.rb
class OrderCreationService
  def initialize(stripe_session, cart)
    @stripe_session = stripe_session
    @cart = cart
  end

  def call
    # Order creation logic
  end
end
```

### 3.5 Missing Service Objects
**Priority:** MEDIUM

**Issue:** Business logic scattered across controllers and models.

**Recommendation:** Create service objects for:
- `CartMergeService` - Merging guest cart into user cart on login
- `OrderCreationService` - Order creation from Stripe session
- `InventoryManagementService` - Stock tracking (when implemented)
- `ProductImportService` - Bulk product imports

### 3.6 Unused Database Fields
**Priority:** LOW
**Location:** `products` table

**Issue:** Fields like `pac_size`, `sku`, `material` on products table are not consistently used.

**Recommendation:**
- Audit which fields are actually needed
- Remove unused fields or document their purpose
- Consolidate with variant fields

---

## 4. Testing & Quality Assurance

### 4.1 Missing Controller Tests
**Priority:** HIGH
**Location:** `test/controllers/`

**Issue:** No controller tests found in the codebase.

**Impact:**
- Regression risks
- No confidence in endpoint behavior
- Critical flows untested (checkout, cart, admin)

**Recommendation:** Add tests for:
- `CheckoutsController` (critical payment flow)
- `CartItemsController` (cart operations)
- `Admin::ProductsController` (authorization)
- `Admin::OrdersController`

### 4.2 Missing Integration Tests
**Priority:** HIGH

**Issue:** No system/integration tests for:
- Complete checkout flow
- Cart to order conversion
- Guest to user cart migration
- Admin product management

**Recommendation:**
```ruby
# test/system/checkout_flow_test.rb
class CheckoutFlowTest < ApplicationSystemTestCase
  test "complete checkout flow" do
    # Add product to cart
    # Proceed to checkout
    # Mock Stripe response
    # Verify order creation
  end
end
```

### 4.3 Missing Model Test Coverage
**Priority:** MEDIUM

**Issue:** Only `ProductTest` found. Missing tests for:
- `Cart` (VAT calculation, totals)
- `Order` (order number generation, validations)
- `CartItem` (price calculation)
- `ProductVariant` (stock tracking)

### 4.4 No Test Coverage Tracking
**Priority:** MEDIUM

**Issue:** No test coverage tools configured (SimpleCov).

**Recommendation:**
```ruby
# Gemfile
group :test do
  gem 'simplecov', require: false
end

# test/test_helper.rb
require 'simplecov'
SimpleCov.start 'rails'
```

---

## 5. Missing Features & TODOs

### 5.1 Stock Tracking Not Implemented
**Priority:** HIGH
**Location:** `app/models/product_variant.rb:58-63`

**Issue:** `in_stock?` method always returns `true`. No stock management.

**Impact:**
- Can oversell products
- No inventory management
- Customer satisfaction issues

**Recommendation:**
- Implement stock decrement on order creation
- Add low stock alerts
- Prevent checkout when out of stock
- Add stock reconciliation jobs

### 5.2 No Order Status Transitions
**Priority:** HIGH

**Issue:** Order status enum defined but no workflow for status changes.

**Impact:**
- Orders stuck in "paid" status
- No fulfillment tracking
- No customer notifications for status changes

**Recommendation:**
- Implement state machine (AASM or Statesman gem)
- Add admin UI for status updates
- Send email notifications on status changes
- Add status change audit log

### 5.3 Missing Email Verification Flow
**Priority:** MEDIUM

**Issue:** `email_address_verified` field exists but verification flow incomplete.

**Recommendation:**
- Send verification emails on registration
- Prevent certain actions until verified
- Add resend verification email functionality

### 5.4 No Password Reset Functionality
**Priority:** MEDIUM
**Location:** `app/controllers/passwords_controller.rb`

**Issue:** Controller exists but implementation not verified.

**Recommendation:**
- Verify password reset flow works end-to-end
- Add expiration to reset tokens
- Rate limit reset requests

### 5.5 Missing Guest Checkout
**Priority:** MEDIUM

**Issue:** Guests can add to cart but no option to checkout without registration.

**Recommendation:**
- Allow guest checkout (collect email at checkout)
- Create user account post-purchase (optional)
- Link orders by email address

### 5.6 No Product Search
**Priority:** MEDIUM

**Issue:** No search functionality for products.

**Recommendation:**
- Add PgSearch for PostgreSQL full-text search
- Search by name, SKU, description
- Add search results page
- Consider Elasticsearch for advanced search

### 5.7 Missing Product Reviews/Ratings
**Priority:** LOW

**Recommendation:**
- Add `Review` model
- Associate with products and users
- Display average rating
- Moderate reviews before publishing

---

## 6. Database & Data Model

### 6.1 No Soft Delete Strategy
**Priority:** MEDIUM

**Issue:** Products and variants use `active` flag but not consistently.

**Recommendation:**
- Implement proper soft delete with `paranoia` gem or `discard` gem
- Preserve order history even if products deleted
- Add `deleted_at` timestamp

### 6.2 Missing Audit Trail
**Priority:** MEDIUM

**Issue:** No tracking of:
- Order modifications
- Price changes
- Admin actions

**Recommendation:**
- Add `paper_trail` gem for versioning
- Track changes to orders, products, prices
- Admin action logging

### 6.3 No Database Constraints for Business Rules
**Priority:** MEDIUM

**Issue:** Critical business rules only enforced at application level.

**Recommendation:**
```ruby
# Add check constraints
add_check_constraint :orders, "total_amount >= 0", name: "total_amount_check"
add_check_constraint :cart_items, "quantity > 0", name: "quantity_check"
add_check_constraint :product_variants, "price > 0", name: "price_check"
```

### 6.4 Missing Order Item Product Reference
**Priority:** LOW
**Location:** `db/schema.rb:76-84`

**Issue:** `order_items.product_id` is nullable and stores denormalized data.

**Recommendation:**
- Since product names and SKUs are denormalized (good for historical accuracy), consider removing `product_id` foreign key entirely
- Or keep it for reporting but make it clear it's optional

### 6.5 No Database Backup Strategy Documented
**Priority:** HIGH

**Issue:** No documentation of backup/restore procedures.

**Recommendation:**
- Document backup schedule
- Test restore procedures
- Consider point-in-time recovery setup
- Store backups in multiple locations

---

## 7. Frontend Improvements

### 7.1 No Frontend Error Handling
**Priority:** MEDIUM
**Location:** `app/frontend/javascript/controllers/`

**Issue:** Stimulus controllers don't handle errors gracefully.

**Recommendation:**
```javascript
// Add error handling to cart drawer controller
open(event) {
  try {
    if (event.detail.success) {
      const drawer = document.querySelector('#cart-drawer')
      if (!drawer) {
        console.error('Cart drawer element not found')
        return
      }
      drawer.checked = true
    }
  } catch (error) {
    console.error('Error opening cart drawer:', error)
  }
}
```

### 7.2 No Loading States
**Priority:** MEDIUM

**Issue:** No visual feedback during:
- Adding to cart
- Updating quantities
- Checkout redirect

**Recommendation:**
- Add loading spinners
- Disable buttons during submission
- Use Turbo Frame loading states

### 7.3 No Client-Side Validation
**Priority:** MEDIUM

**Issue:** Form validation only server-side.

**Recommendation:**
- Add HTML5 validation attributes
- Stimulus controller for real-time validation
- Better UX with immediate feedback

### 7.4 Accessibility Issues
**Priority:** MEDIUM

**Issue:** No ARIA labels, semantic HTML review needed.

**Recommendation:**
- Audit with Lighthouse
- Add proper ARIA labels
- Keyboard navigation testing
- Screen reader testing

### 7.5 No Mobile Optimization Review
**Priority:** LOW

**Issue:** Responsive design not verified on all devices.

**Recommendation:**
- Test on various devices and screen sizes
- Optimize touch targets
- Mobile-specific UX improvements

---

## 8. DevOps & Monitoring

### 8.1 No Application Performance Monitoring
**Priority:** HIGH

**Issue:** No APM tool configured (Scout, Skylight, New Relic).

**Recommendation:**
- Add APM for production monitoring
- Track slow queries
- Monitor error rates
- Set up alerts

### 8.2 No Error Tracking
**Priority:** HIGH

**Issue:** No error tracking service (Sentry, Rollbar, Honeybadger).

**Recommendation:**
- Integrate Sentry or similar
- Track JavaScript errors
- Set up error notifications
- Group and prioritize errors

### 8.3 No Logging Strategy
**Priority:** MEDIUM

**Issue:** Basic Rails logging only, no structured logging.

**Recommendation:**
- Add structured logging (Lograge)
- Log important business events
- Separate audit logs
- Consider centralized logging (Papertrail, Splunk)

### 8.4 No Health Check Endpoints
**Priority:** MEDIUM

**Issue:** Only basic `/up` endpoint exists.

**Recommendation:**
- Add detailed health checks:
  - Database connectivity
  - Redis connectivity (if used)
  - External service status (Stripe, Mailgun)
  - Disk space
  - Job queue status

### 8.5 No CI/CD Pipeline Documented
**Priority:** MEDIUM

**Issue:** No documented deployment process or CI/CD.

**Recommendation:**
- Document deployment process
- Set up GitHub Actions or similar
- Automate tests before deployment
- Add staging environment

---

## 9. Documentation

### 9.1 Missing API Documentation
**Priority:** MEDIUM

**Issue:** No documentation for internal APIs or future API endpoints.

**Recommendation:**
- Document expected request/response formats
- If building API, add OpenAPI/Swagger
- Document webhook endpoints

### 9.2 No Architecture Decision Records (ADRs)
**Priority:** LOW

**Issue:** No documentation of why certain architectural decisions were made.

**Recommendation:**
- Create ADRs for major decisions
- Example: Why Vite over Webpacker/Importmap
- Document trade-offs

### 9.3 Missing Runbook
**Priority:** MEDIUM

**Issue:** No operational runbook for common issues.

**Recommendation:**
- How to handle failed payments
- How to refund orders
- How to handle customer complaints
- Database backup/restore procedures

---

## 10. Configuration & Environment

### 10.1 Missing Environment-Specific Configurations
**Priority:** MEDIUM

**Issue:** Some configurations hardcoded that should be environment variables.

**Recommendation:**
```ruby
# Shipping costs should be configurable
STANDARD_SHIPPING_COST = ENV.fetch('STANDARD_SHIPPING_COST', '500').to_i
EXPRESS_SHIPPING_COST = ENV.fetch('EXPRESS_SHIPPING_COST', '1000').to_i
```

### 10.2 No Secrets Rotation Strategy
**Priority:** MEDIUM

**Issue:** No documented process for rotating API keys, passwords.

**Recommendation:**
- Document secret rotation procedures
- Regular rotation schedule
- Use credential management tools

### 10.3 Missing Feature Flags
**Priority:** LOW

**Issue:** No feature flag system for gradual rollouts.

**Recommendation:**
- Add Flipper gem
- Enable/disable features without deployment
- A/B testing capabilities

---

## 11. Business Logic & Validation

### 11.1 Inconsistent Price Handling
**Priority:** HIGH
**Location:** `app/models/cart_item.rb:20-22`

**Issue:** Price is set from variant only if blank, but variant price could change after cart item is created.

**Impact:**
- Price discrepancies
- Customer complaints
- Revenue loss

**Recommendation:**
- Decide on pricing strategy:
  - Lock price at cart addition (current approach) ✓
  - Or use current variant price at checkout
- Add price change warnings if variant price changes
- Consider price validity period

### 11.2 No Minimum Order Amount
**Priority:** LOW

**Issue:** No minimum order validation.

**Recommendation:**
- Add minimum order amount
- Validate in checkout
- Show message to user

### 11.3 No Maximum Quantity Limits
**Priority:** MEDIUM

**Issue:** No limits on cart item quantities.

**Recommendation:**
- Add max quantity per item
- Add max total items in cart
- Prevent abuse

### 11.4 VAT Handling Not Flexible
**Priority:** MEDIUM

**Issue:** VAT rate hardcoded at 20% for all products.

**Impact:**
- Can't sell to non-UK customers
- Can't handle VAT-exempt products
- International expansion blocked

**Recommendation:**
- Store VAT rate per product/category
- Calculate VAT based on shipping country
- Add VAT exemption logic
- Consider tax calculation service (TaxJar, Avalara)

---

## 12. Quick Wins (Low Effort, High Value)

### 12.1 Add Brakeman Security Scanner to CI
```ruby
# Gemfile
gem 'brakeman', group: :development
```

### 12.2 Add bundle-audit for Dependency Vulnerabilities
```ruby
# Gemfile
gem 'bundler-audit', group: :development
```

### 12.3 Add Database Annotations
```ruby
# Gemfile
gem 'annotate', group: :development
```

### 12.4 Add Bullet Gem for N+1 Detection
```ruby
# Gemfile
gem 'bullet', group: :development
```

### 12.5 Add Rubocop Rails Omakase
Already mentioned in CLAUDE.md but verify it's configured.

---

## Priority Matrix

### Must Fix Before Launch
1. Admin authentication vulnerability
2. Stripe tax rate creation issue
3. Stock tracking implementation
4. Rate limiting
5. Error tracking setup
6. Database backups

### Should Fix Soon
1. Missing tests (controller & integration)
2. N+1 queries
3. Order status workflow
4. Database indexes
5. APM setup
6. Caching strategy

### Nice to Have
1. Product search
2. Guest checkout
3. Feature flags
4. Product reviews
5. Mobile optimization
6. Architecture decision records

---

## Estimated Effort

| Category | Items | Estimated Days |
|----------|-------|----------------|
| Critical Security | 4 | 3-5 days |
| Performance | 5 | 5-7 days |
| Testing | 4 | 10-15 days |
| Missing Features | 7 | 15-20 days |
| Code Quality | 6 | 7-10 days |
| DevOps | 5 | 5-7 days |
| Documentation | 3 | 2-3 days |

**Total: 47-67 days of development effort**

---

## Next Steps

1. **Immediate (This Week):**
   - Fix admin authentication bug
   - Add rate limiting
   - Set up error tracking
   - Fix Stripe tax rate creation

2. **Short Term (This Month):**
   - Add controller tests
   - Implement stock tracking
   - Add database indexes
   - Set up APM

3. **Medium Term (This Quarter):**
   - Complete test coverage
   - Implement order workflow
   - Add product search
   - Performance optimization

4. **Long Term (Ongoing):**
   - Refactor to service objects
   - Improve documentation
   - Add advanced features
   - International expansion prep

---

## Contributing

When working on technical debt:
1. Create an issue referencing this document
2. Break large items into smaller tasks
3. Add tests for fixed issues
4. Update this document when items are resolved
5. Document any new technical debt created

---

**Document Version:** 1.0
**Next Review:** 2025-11-15
