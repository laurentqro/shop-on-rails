# Branded Products System

## Overview

The branded products system allows B2B customers to order custom branded packaging with their own designs. After the first order is manufactured, customers can reorder from their dashboard.

## User Workflow

### 1. Initial Order (Customer)
1. Browse customizable products (e.g., "Double Wall Branded Cups")
2. Configure product:
   - Select size (8oz, 12oz, 16oz)
   - Select quantity tier (1000, 2000, 5000, etc.)
   - Upload design file (PDF, PNG, JPG, AI)
3. Add to cart and checkout
4. Order is marked as "design_pending"

### 2. Fulfillment (Admin)
1. View order in Admin > Branded Orders
2. Download customer's design file
3. Update status through fulfillment stages:
   - Design Pending → Design Approved
   - Design Approved → In Production
   - In Production → Production Complete
   - Production Complete → Stock Received
4. When stock arrives, create customer product instance:
   - Auto-filled product name, SKU, stock quantity
   - Set reorder price
   - Copies design to product images
5. Status automatically updates to "Instance Created"
6. Customer is notified their product is ready

### 3. Reorders (Customer)
1. Navigate to "My Branded Products"
2. View all their custom products
3. Select product and quantity
4. Add to cart like standard product
5. No design upload needed (already on file)

## Data Model

### Organizations
- B2B customers belong to organizations
- Team members share access to branded products
- Individual consumers don't have organizations

### Product Types
- **standard**: Regular products with variants (size/color options)
- **customizable_template**: Configurator products (branded cups)
- **customized_instance**: Customer-specific products created after manufacturing

### Pricing
- BrandedProductPrice stores pricing matrix (size × quantity tier)
- BrandedProductPricingService calculates prices based on configuration
- CartItem stores calculated_price at add-to-cart time

### Configuration Storage
- CartItem.configuration: Selected options before purchase
- OrderItem.configuration: Preserved configuration after purchase
- Product.configuration_data: Instance product specifications

## Technical Architecture

### Services
- **BrandedProductPricingService**: Calculate prices from matrix
- **ProductVariantGeneratorService**: Generate variants for standard products
- **BrandedProducts::InstanceCreatorService**: Create customer products

### Controllers
- **BrandedProducts::ConfiguratorController**: AJAX pricing API
- **Organizations::ProductsController**: Customer dashboard
- **Admin::BrandedOrdersController**: Fulfillment workflow

### Stimulus Controllers
- **branded_configurator_controller.js**: Interactive configurator UI

## Configuration

### Pricing Import
Import pricing from CSV:
```ruby
# In db/seeds/branded_product_pricing.rb
pricing_data = [
  { size: "8oz", quantity: 1000, price: 0.26, case_qty: 1000 },
  # ...
]
```

### Product Options
Global reusable options (Size, Color, Material):
```ruby
# In db/seeds/product_options.rb
size_option = ProductOption.create!(name: "Size", display_type: "dropdown")
size_option.values.create!(value: "8oz", position: 1)
```

## Testing

Run branded product tests:
```bash
rails test test/models/branded_product_price_test.rb
rails test test/services/branded_products/
rails test test/controllers/branded_products/
rails test:system test/system/branded_product_ordering_test.rb
```

## Database Schema

### Core Tables

#### products
- `product_type` - standard, customizable_template, customized_instance
- `organization_id` - null for standard/template, set for instances
- `configuration_data` - JSONB for instance specifications
- `based_on_product_id` - References template product for instances

#### branded_product_prices
- `product_id` - Template product reference
- `size` - Cup size (8oz, 12oz, 16oz)
- `quantity_tier` - Minimum order quantity (1000, 2000, etc.)
- `price_per_unit` - Price in pounds
- `case_quantity` - Units per case

#### order_items
- `configuration` - JSONB storing selected options
- `design_file` - ActiveStorage attachment
- `fulfillment_status` - design_pending, design_approved, in_production, etc.

#### product_variants
- `option_values` - JSONB hash of selected options (size: "8oz", color: "White")

#### product_options / product_option_values
- Global reusable options (Size, Color, Material)
- Linked to products via product_product_options

## Routes

### Customer Routes
```ruby
# Configurator
GET    /products/:slug/configure      # Show configurator
POST   /branded_products/calculate_price  # AJAX pricing API

# Organization Dashboard
GET    /organization/products         # List customer's branded products
GET    /organization/products/:id     # Show product details
POST   /organization/products/:id/add_to_cart  # Quick reorder

# Regular product routes work for adding configured products to cart
```

### Admin Routes
```ruby
namespace :admin do
  resources :branded_orders do
    member do
      patch :update_status
      post  :create_instance
    end
  end
end
```

## Models

### Product
```ruby
# Enums
enum product_type: {
  standard: "standard",
  customizable_template: "customizable_template",
  customized_instance: "customized_instance"
}

# Associations
belongs_to :organization, optional: true
belongs_to :based_on_product, class_name: "Product", optional: true
has_many :product_instances, class_name: "Product", foreign_key: :based_on_product_id

# Scopes
scope :standard, -> { where(product_type: "standard") }
scope :customizable_templates, -> { where(product_type: "customizable_template") }
scope :for_organization, ->(org) { where(organization: org) }

# Methods
def customizable? # Returns true if product has configurator
def customer_product? # Returns true if owned by organization
```

### OrderItem
```ruby
# Enums
enum fulfillment_status: {
  design_pending: "design_pending",
  design_approved: "design_approved",
  in_production: "in_production",
  production_complete: "production_complete",
  stock_received: "stock_received",
  instance_created: "instance_created"
}

# Associations
has_one_attached :design_file

# Methods
def customized? # Returns true if has configuration
def awaiting_fulfillment? # Returns true if branded and not complete
```

### BrandedProductPrice
```ruby
# Validations
validates :product, :size, :quantity_tier, :price_per_unit, presence: true
validates :quantity_tier, numericality: { greater_than: 0 }
validates :price_per_unit, numericality: { greater_than: 0 }

# Scopes
scope :for_product, ->(product) { where(product: product) }
scope :for_size, ->(size) { where(size: size) }
scope :ascending_quantity, -> { order(quantity_tier: :asc) }

# Methods
def total_price # Calculates quantity_tier * price_per_unit
def price_per_case # Calculates case pricing
```

## Services

### BrandedProductPricingService
```ruby
# Usage
service = BrandedProductPricingService.new(product)
result = service.calculate(size: "12oz", quantity: 2500)

# Returns
{
  success: true,
  price_per_unit: 0.24,
  total_price: 600.00,
  quantity: 2500,
  size: "12oz",
  matched_tier: 2000,
  case_quantity: 1000,
  number_of_cases: 2.5
}
```

Pricing logic:
1. Finds prices for product and size
2. Selects highest tier <= requested quantity
3. Uses that tier's price_per_unit
4. Calculates total = quantity × price_per_unit

### BrandedProducts::InstanceCreatorService
```ruby
# Usage
service = BrandedProducts::InstanceCreatorService.new(order_item)
result = service.create

# Creates
- Product with product_type: "customized_instance"
- Linked to customer's organization
- Copies configuration from order_item
- Generates SKU from template + order
- Transfers design file to product images
```

### ProductVariantGeneratorService
```ruby
# Usage
service = ProductVariantGeneratorService.new(product)
service.generate_variants

# For standard products with options
# Generates all combinations of selected options
# Creates ProductVariant for each with option_values
```

## Views

### Configurator Page (`products/show.html.erb`)
```html
<div data-controller="branded-configurator">
  <!-- Size selector -->
  <select data-branded-configurator-target="sizeSelect">
    <option value="8oz">8oz</option>
    <option value="12oz">12oz</option>
    <option value="16oz">16oz</option>
  </select>

  <!-- Quantity selector -->
  <select data-branded-configurator-target="quantitySelect">
    <option value="1000">1000+ cups</option>
    <option value="2000">2000+ cups</option>
    <option value="5000">5000+ cups</option>
  </select>

  <!-- Design file upload -->
  <input type="file"
         data-branded-configurator-target="designUpload"
         accept=".pdf,.png,.jpg,.jpeg,.ai">

  <!-- Live pricing display -->
  <div data-branded-configurator-target="priceDisplay">
    <span class="price">£0.00</span>
    <span class="breakdown">0 cups × £0.00</span>
  </div>

  <!-- Add to cart -->
  <form data-branded-configurator-target="cartForm">
    <input type="hidden" name="configuration[size]">
    <input type="hidden" name="configuration[quantity]">
    <input type="hidden" name="design_file">
    <button>Add to Cart</button>
  </form>
</div>
```

### Admin Branded Orders (`admin/branded_orders/index.html.erb`)
```html
<table>
  <thead>
    <tr>
      <th>Order #</th>
      <th>Customer</th>
      <th>Product</th>
      <th>Configuration</th>
      <th>Status</th>
      <th>Design</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <% @order_items.each do |item| %>
      <tr>
        <td><%= link_to item.order.order_number, admin_order_path(item.order) %></td>
        <td><%= item.order.user.email %></td>
        <td><%= item.product.name %></td>
        <td>
          <%= item.configuration["size"] %> ×
          <%= item.configuration["quantity"] %>
        </td>
        <td>
          <span class="badge badge-<%= item.fulfillment_status %>">
            <%= item.fulfillment_status.humanize %>
          </span>
        </td>
        <td>
          <% if item.design_file.attached? %>
            <%= link_to "Download", rails_blob_path(item.design_file, disposition: "attachment") %>
          <% end %>
        </td>
        <td>
          <%= form_with model: item, url: update_status_admin_branded_order_path(item), method: :patch do |f| %>
            <%= f.select :fulfillment_status, OrderItem.fulfillment_statuses.keys %>
            <%= f.submit "Update" %>
          <% end %>

          <% if item.stock_received? %>
            <%= button_to "Create Instance", create_instance_admin_branded_order_path(item), method: :post %>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
```

### Organization Products Dashboard (`organizations/products/index.html.erb`)
```html
<h1>My Branded Products</h1>

<div class="products-grid">
  <% @products.each do |product| %>
    <div class="product-card">
      <%= image_tag product.image_url %>

      <h3><%= product.name %></h3>

      <dl class="specs">
        <dt>Size:</dt>
        <dd><%= product.configuration_data["size"] %></dd>

        <dt>Original Order:</dt>
        <dd><%= product.configuration_data["quantity"] %> cups</dd>

        <dt>Stock:</dt>
        <dd><%= product.default_variant.stock %> remaining</dd>

        <dt>Reorder Price:</dt>
        <dd>£<%= product.default_variant.price %> per case</dd>
      </dl>

      <%= link_to "View Details", organization_product_path(product), class: "btn" %>

      <%= form_with url: add_to_cart_organization_product_path(product), method: :post do |f| %>
        <%= f.number_field :quantity, value: 1, min: 1 %>
        <%= f.submit "Quick Reorder" %>
      <% end %>
    </div>
  <% end %>
</div>
```

## Stimulus Controller

### branded_configurator_controller.js
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sizeSelect", "quantitySelect", "designUpload",
                    "priceDisplay", "cartForm"]

  connect() {
    this.updatePrice()
  }

  // Called when size or quantity changes
  updatePrice() {
    const size = this.sizeSelectTarget.value
    const quantity = this.quantitySelectTarget.value

    if (!size || !quantity) return

    // AJAX request to pricing API
    fetch("/branded_products/calculate_price", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({
        product_id: this.element.dataset.productId,
        size: size,
        quantity: quantity
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.displayPrice(data)
      } else {
        this.displayError(data.error)
      }
    })
  }

  displayPrice(data) {
    const price = data.total_price.toFixed(2)
    const perUnit = data.price_per_unit.toFixed(4)

    this.priceDisplayTarget.innerHTML = `
      <span class="price">£${price}</span>
      <span class="breakdown">${data.quantity} cups × £${perUnit}</span>
      <span class="cases">${data.number_of_cases} cases of ${data.case_quantity}</span>
    `

    // Update hidden form fields
    this.cartFormTarget.querySelector('[name="configuration[size]"]').value = data.size
    this.cartFormTarget.querySelector('[name="configuration[quantity]"]').value = data.quantity
    this.cartFormTarget.querySelector('[name="configuration[price]"]').value = data.total_price
  }

  // Validate design upload
  validateDesign() {
    const file = this.designUploadTarget.files[0]
    if (!file) return false

    const validTypes = ['application/pdf', 'image/png', 'image/jpeg',
                       'application/postscript', 'application/illustrator']
    const maxSize = 10 * 1024 * 1024 // 10MB

    if (!validTypes.includes(file.type)) {
      alert("Please upload a PDF, PNG, JPG, or AI file")
      return false
    }

    if (file.size > maxSize) {
      alert("File must be under 10MB")
      return false
    }

    return true
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
```

## Security Considerations

### File Upload Validation
- Validate file types (PDF, PNG, JPG, AI only)
- Limit file size (10MB max)
- Scan for malware in production
- Store in private storage, not public

### Authorization
- Customers can only view their organization's products
- Admin authentication required for branded orders section
- Design files require authentication to download

### Data Privacy
- Organization products are private (not searchable/indexable)
- Design files not exposed in public URLs
- Customer configurations stored securely

## Performance Considerations

### Database Indexes
```ruby
add_index :products, [:organization_id, :product_type]
add_index :products, :based_on_product_id
add_index :order_items, :fulfillment_status
add_index :branded_product_prices, [:product_id, :size, :quantity_tier]
```

### Caching
- Cache pricing matrix per product
- Cache organization product lists
- Eager load associations in admin views

### Background Jobs
Consider moving to background jobs:
- Design file processing
- Product instance creation
- Email notifications

## Future Enhancements

- Auto-replenishment when stock runs low
- Design approval workflow with customer feedback
- Pricing tiers based on customer volume
- Multiple design variants per product
- Design guidelines PDF generator
- Bulk reorder interface
- Analytics dashboard for customer usage
- Integration with manufacturing system
- Automated stock level alerts
- Customer design history/versioning

## Troubleshooting

### Pricing not calculating
- Check BrandedProductPrice records exist for product
- Verify size and quantity tier match database values
- Check console for JavaScript errors
- Verify API endpoint is responding

### Design file not uploading
- Check Active Storage configuration
- Verify file size under limit
- Check file type is allowed
- Verify CORS settings if using S3

### Instance creation failing
- Check organization exists for user
- Verify order_item has required configuration
- Check product template still exists
- Verify design file is attached

### Products not showing in dashboard
- Verify user belongs to organization
- Check product has product_type: "customized_instance"
- Verify product.organization_id matches user's org
- Check product is active

## Support

For questions or issues:
1. Check test suite for examples
2. Review service objects for business logic
3. Check controller actions for API usage
4. Consult admin interface for workflow
