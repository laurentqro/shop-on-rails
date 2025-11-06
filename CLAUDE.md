# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8 e-commerce application for selling eco-friendly catering supplies. The application uses Vite for frontend asset bundling with TailwindCSS 4 and DaisyUI for styling, Hotwire (Turbo + Stimulus) for interactivity, Stripe for payments, and PostgreSQL as the database.

## Development Commands

### Initial Setup
```bash
bin/setup               # Install dependencies, setup database, and start server
bin/setup --skip-server # Setup without starting the server
```

### Running the Application
```bash
bin/dev                 # Start Rails server and Vite dev server (uses foreman)
rails server            # Run Rails server only (port 3000)
bin/vite dev            # Run Vite dev server only
```

### Database Commands
```bash
rails db:migrate        # Run pending migrations
rails db:seed           # Seed the database
rails db:prepare        # Create database if needed and run migrations
rails db:reset          # Drop, create, migrate, and seed database
```

### Testing
```bash
rails test              # Run all tests
rails test:system       # Run system tests (uses Capybara + Selenium)
rails test test/models/product_test.rb              # Run a specific test file
rails test test/models/product_test.rb:10           # Run specific test by line number
```

### Code Quality
```bash
rubocop                 # Run RuboCop linter (uses rails-omakase config)
brakeman                # Run security vulnerability scanner
```

### Asset Management
Vite automatically compiles assets during development. For production builds:
```bash
bin/vite build          # Build assets for production
```

### Rails Console
```bash
rails console           # Open Rails console
rails c                 # Shorthand
```

## Architecture Overview

### Frontend Architecture (Vite + Rails)

**Asset Pipeline**: Uses Vite Rails instead of traditional Sprockets/Propshaft
- Entry points: `app/frontend/entrypoints/application.js` and `application.css`
- Assets organized in `app/frontend/` directory (images, fonts, stylesheets, javascript)
- Vite config: `vite.config.mts` with TailwindCSS 4 plugin and Rails integration
- Auto-reload on changes to routes and views

**JavaScript Stack**:
- Hotwire Turbo for SPA-like navigation
- Stimulus controllers for interactive components (`app/frontend/javascript/controllers/`)
  - `carousel_controller.js` - Swiper.js carousel integration
  - `cart_drawer_controller.js` - Shopping cart drawer functionality
- Swiper for carousels
- Active Storage for file uploads

**Styling**:
- TailwindCSS 4 for utility-first styling
- DaisyUI component library for pre-built UI components
- Custom styles in `app/frontend/stylesheets/`

### Backend Architecture

**Models**:
- `Product` - Has variants, belongs to category, uses slugs for URLs
  - Default scope filters active products and orders by sort_order
  - `ProductVariant` - Price and inventory tracking (SKU, stock, price)
- `Category` - Organizes products
- `Cart` / `CartItem` - Shopping cart (supports both guest and user carts)
  - VAT calculation at 20% (UK)
  - Cart can belong to user or be guest cart
- `Order` / `OrderItem` - Completed purchases
  - Stores Stripe session ID
  - Captures shipping details from Stripe Checkout
- `User` / `Session` - Authentication (Rails 8 built-in authentication with bcrypt)
- `Current` - ActiveSupport::CurrentAttributes for request-scoped state (user, session, cart)

**Controllers**:
- `PagesController` - Static pages (home, shop, about, contact, terms, privacy, cookies)
- `ProductsController` - Product listing and detail pages
- `CategoriesController` - Category pages
- `CartsController` / `CartItemsController` - Shopping cart management
- `CheckoutsController` - Stripe Checkout integration
  - Creates Stripe sessions with line items, shipping, and tax
  - Handles success callback to create orders
  - Uses `Current.cart` for cart state
- `OrdersController` - Order history and details
- `Admin::ProductsController` - Admin product management
- `Admin::OrdersController` - Admin order management
- `FeedsController` - Google Merchant feed generation

**Key Patterns**:
- Uses slugs for SEO-friendly URLs (`Product#to_param` returns slug)
- Products have variants for different sizes/options
- Authentication uses Rails 8 built-in patterns with `allow_unauthenticated_access` macro
- Guest carts tracked by cookie, merged on user login
- VAT calculated on checkout (20% UK rate)
- Stripe Checkout for payment processing with shipping address collection

### Database Configuration

**Multi-database setup** for production (Solid Queue, Solid Cache, Solid Cable):
- Primary: Main application data (PostgreSQL)
- Cache: Solid Cache database
- Queue: Solid Queue for background jobs
- Cable: Solid Cable for Action Cable

Development uses single PostgreSQL database: `shop_development`

### Payment Flow (Stripe)

1. User clicks checkout → `CheckoutsController#create`
2. Creates Stripe Checkout Session with:
   - Line items from cart
   - UK VAT (20%) as tax rate
   - Shipping address collection (GB only)
   - Standard and Express shipping options
3. User completes payment on Stripe
4. Stripe redirects to `CheckoutsController#success` with session_id
5. Retrieves Stripe session, creates Order and OrderItems
6. Clears cart and sends confirmation email
7. Prevents duplicate orders by checking `stripe_session_id`

### Email Configuration

- Uses Mailgun gem for transactional emails
- Order confirmation emails sent via `OrderMailer`
- Registration emails for email verification
- Password reset functionality

### Third-Party Services

**Required credentials** (stored in Rails encrypted credentials):
- Stripe API keys (test and live)
- Mailgun API credentials
- AWS S3 credentials (for Active Storage in production)

Edit credentials:
```bash
rails credentials:edit
```

## Important File Locations

- Routes: `config/routes.rb`
- Database schema: `db/schema.rb`
- Vite entrypoints: `app/frontend/entrypoints/`
- Stimulus controllers: `app/frontend/javascript/controllers/`
- View components: `app/views/`
- Credentials: `config/credentials.yml.enc` (use `rails credentials:edit`)

## Development Tips

### Working with Products
- Products require a category and generate slugs automatically from name/SKU/colour
- Always work with `product.active_variants` not `product.variants` (filters inactive)
- Use `product.default_variant` for single variant products
- Price range calculated from all active variants

### Working with Product Photos

Products and variants support two photo types:
- **Product Photo** (`:product_photo`) - Close-up product shot
- **Lifestyle Photo** (`:lifestyle_photo`) - Staged in real-life context

Both photos are optional. Helper methods:
- `product.primary_photo` - Returns product_photo if present, else lifestyle_photo
- `product.photos` - Array of all attached photos
- `product.has_photos?` - Returns true if any photo attached

**Product Cards**: Display product_photo by default, hover shows lifestyle_photo (when both present)

**Admin**: Separate upload fields for each photo type

**Cart/Thumbnails**: Use `primary_photo` for smart fallback

### Working with Cart
- Use `Current.cart` to access current user's cart
- Cart automatically handles guest vs authenticated users
- VAT calculated at `Cart::VAT_RATE` (0.2)
- Cart methods: `items_count`, `subtotal_amount`, `vat_amount`, `total_amount`

### Authentication
- Uses Rails 8 authentication with Session model
- Allow public access with `allow_unauthenticated_access` in controllers
- Current user available via `Current.user`
- Session stored in encrypted cookie

### Admin Area
- Namespaced under `/admin`
- Manage products and variants
- View and manage orders
- Add authentication checks before deploying to production

### Testing Payments Locally
Use Stripe test mode card numbers:
- Success: `4242 4242 4242 4242`
- Requires authentication: `4000 0025 0000 3155`
- Declined: `4000 0000 0000 9995`

### Google Merchant Feed
- Available at `/feeds/google-merchant.xml`
- Auto-generates product feed for Google Shopping
- Includes product data, pricing, images, and availability

## SEO Implementation

### Overview

Comprehensive SEO implementation with structured data, sitemaps, canonical URLs, and meta tags across all pages.

### Structured Data (JSON-LD)

**Available helpers** (`app/helpers/seo_helper.rb`):

```ruby
# Product structured data with Schema.org Product markup
product_structured_data(product, variant)

# Organization structured data (Afida company info)
organization_structured_data

# Breadcrumb navigation structured data
breadcrumb_structured_data(items)

# Canonical URL tag
canonical_url(url = nil)
```

**Implemented on:**
- Product pages: Product + Breadcrumb structured data
- Branded product pages: Product (AggregateOffer) + Breadcrumb
- Category pages: CollectionPage + Breadcrumb
- All pages: Organization structured data (in head via footer partial)

### Sitemaps

**XML Sitemap:**
- Route: `/sitemap.xml`
- Controller: `SitemapsController`
- Service: `SitemapGeneratorService` (generates sitemap with priorities and change frequencies)
- Includes: Home, static pages, all categories, all products, FAQs

**Robots.txt:**
- Route: `/robots.txt` (dynamic controller)
- Controller: `RobotsController`
- Includes sitemap reference, allows all except `/admin/`, `/cart`, `/checkout`

### Meta Tags

**All pages include:**
- Title tag (via `content_for :title`)
- Meta description (via `content_for :meta_description`)
- Canonical URL (automatic via `application.html.erb`)

**Product and Category pages:**
- Use database fields `meta_title` and `meta_description` when present
- Fallback to generated values when blank
- Products: Falls back to "#{name} | #{category.name} | Afida"
- Categories: Uses `meta_title` and `meta_description` from database

**Home and important pages:**
- Open Graph tags (og:title, og:description, og:type, og:url)
- Twitter Card tags
- Custom optimized titles and descriptions

### SEO Validation

**Rake task:**
```bash
rails seo:validate
```

**What it checks:**
- Products missing custom meta_title or meta_description
- Categories missing meta_title or meta_description
- Displays summary of SEO coverage

### Testing

**System tests:**
- `test/system/seo_test.rb` - Canonical URLs on product/category pages
- `test/system/product_structured_data_test.rb` - Structured data on products
- `test/system/home_page_seo_test.rb` - Home page meta tags

**Integration tests:**
- `test/integration/comprehensive_seo_test.rb` - End-to-end SEO validation
- `test/integration/product_meta_tags_test.rb` - Database field fallback behavior

**Service tests:**
- `test/services/sitemap_generator_service_test.rb` - Sitemap XML generation

**Helper tests:**
- `test/helpers/seo_helper_test.rb` - Structured data helper methods

### Next Steps

After deploying SEO updates:
1. Run `rails seo:validate` to check coverage
2. Test sitemap at `yoursite.com/sitemap.xml`
3. Verify robots.txt at `yoursite.com/robots.txt`
4. Test structured data with [Google Rich Results Test](https://search.google.com/test/rich-results)
5. Submit sitemap to Google Search Console
6. Monitor search performance and rankings

### Configuration

**Required environment variables:**
- `APP_HOST` - Used by sitemap generator (e.g., "afida.co.uk")
- Set to production domain in production environment

**Database fields:**
- Products: `meta_title`, `meta_description` (optional, with fallback)
- Categories: `meta_title`, `meta_description` (required)
