# Afida B2C Online Shop — Development Task List

## 1. Global & Homepage Features
- [ ] Implement sitewide Pricing Toggle (Ex VAT / Inc VAT)
- [ ] Build main navigation menu (Shop by Category, Samples, Promotions, Account, Contact)
- [ ] Build footer navigation (About Us, T&Cs, Privacy Policy, Returns Policy, Contact)
- [ ] Implement search bar and search results page (with sorting/filtering)
- [ ] Create promotional banners system (rotating/dynamic, admin-manageable)

## 2. Product Catalog & Listings
- [ ] Build category pages (with subcategories, filtering, sorting)
- [ ] Build product listing pages (grid/list view, VAT toggle, add to cart/view)
- [ ] Implement product detail pages (gallery, description, price, SKU, stock, add to cart, request sample, reviews, related products)

## 3. Product Sample Request System
- [ ] Create dedicated sample request page (browse/search eligible products)
- [ ] Implement multi-select for sample basket (with per-request limit)
- [ ] Build sample request flow (selection, shipping details, shipping payment, confirmation)
- [ ] Admin: Mark products as sample-eligible, set sample limits, manage requests

## 4. Shopping Cart & Checkout
- [ ] Build shopping cart page (update/remove items, estimated shipping, promo code)
- [ ] Implement checkout process (guest/registered, address, shipping, payment, summary, confirmation)
- [ ] Set up email notifications (order confirmation, shipping confirmation, payment status)

## 5. Customer Account Experience
- [ ] Implement sign-up flow (form, newsletter opt-in, post-signup promo banner)
- [ ] Implement login/forgot password flow
- [ ] Build post-login dashboard (orders, reorder, returns, personal details, addresses, tracking, loyalty, recommendations)

## 6. Reward System (Loyalty Program)
- [ ] Implement points system (signup, purchases, conversion to rewards)
- [ ] Build tiered loyalty levels (Bronze, Silver, Gold, Platinum)
- [ ] Track monthly spend and auto-assign tiers
- [ ] Display tier/points/rewards in account dashboard
- [ ] Define and apply tier benefits (discounts, gifts)

## 7. Customer Service / Support System
- [ ] Define issue categories for support
- [ ] Implement chatbot/AI assistant for triage (with flows for each category)
- [ ] Enable live agent escalation (integration TBD)
- [ ] Build contact form/email support
- [ ] Create FAQ page

## 8. Chatbot Features
- [ ] Configure intro prompt and main menu options
- [ ] Implement conditional logic and information gathering flows
- [ ] Integrate with order status API (if available)
- [ ] Enable handoff to live agent system

## 9. Payment Gateways & Credit Accounts
- [ ] Integrate PayPal payment gateway
- [ ] Integrate additional card processor (Stripe/Braintree/Worldpay, TBD)
- [ ] Implement credit account checkout option (admin approval, invoicing, reminders, customer view)
- [ ] Build invoice generation and "Pay Now" button in invoices
- [ ] Set up automated overdue reminders and admin notifications

## 10. Returns System
- [ ] Build online return form and "Return" button in order history
- [ ] Implement return process (submission, admin review, instructions, status updates, refunds)
- [ ] Clearly state return terms (restocking fee, window, overseas, condition)
- [ ] Admin: Manage return requests and process refunds

## 11. Promotions & Marketing
- [ ] Implement "Follow & Share" promo (validation, code redemption)
- [ ] Implement review incentives (submission, validation, voucher issue)
- [ ] Build discount/voucher system (admin creation, conditions, expiry)
- [ ] Implement "Build a Bundle" discount (customer selection, admin management)

## 12. Admin Backend Features
- [ ] Build admin dashboard (sales, orders, customers overview)
- [ ] Product management (CRUD, attributes, sample eligibility)
- [ ] Order management (view, search, status, refunds, sample requests)
- [ ] Customer management (accounts, credit status, order/loyalty history)
- [ ] Promotions management (discounts, bundles, banners)
- [ ] Loyalty program management (rules, tiers, manual adjustments)
- [ ] Content management for static pages
- [ ] Reporting (sales, customers, product performance)
- [ ] Site settings (VAT, shipping, payment, email templates)

## 13. Non-Functional Requirements
- [ ] Ensure responsive design (desktop, tablet, mobile)
- [ ] Implement security best practices (HTTPS, XSS, CSRF, SQLi protection)
- [ ] Optimize performance (page load < 3s)
- [ ] Ensure SEO-friendly URLs and meta tags
- [ ] Meet accessibility (WCAG 2.1 AA) where feasible
- [ ] Ensure browser compatibility (latest Chrome, Firefox, Safari, Edge)
- [ ] Write maintainable, well-commented code

---

*Update this list as requirements evolve or tasks are completed.*