**Product Requirements Document: Afida B2C Online Shop**

**1. Introduction**
This document outlines the product requirements for the Afida B2C Online Shop. The goal is to create a robust, user-friendly e-commerce platform enabling customers to browse products, request samples, make purchases, manage their accounts, and receive support. The platform will be built using Ruby on Rails.

**2. Goals**
*   Launch a fully functional B2C e-commerce website.
*   Provide a seamless and intuitive user experience for browsing, purchasing, and managing orders.
*   Implement a loyalty program to encourage customer retention and repeat purchases.
*   Offer efficient customer support through a combination of self-service, AI, and live agent assistance.
*   Facilitate easy product sample requests to drive conversions.
*   Enable flexible payment options, including credit accounts for eligible customers.

**3. Target Audience**
*   B2C customers (individuals and potentially small businesses) looking to purchase products offered by Afida.
*   Customers who value clear pricing, easy returns, loyalty rewards, and good customer service.

**4. Overall Site & Technical Considerations**
*   **Platform:** Ruby on Rails
*   **Responsive Design:** The website must be fully responsive and provide an optimal viewing experience across desktops, tablets, and mobile devices.
*   **Security:** Implement industry-standard security practices (HTTPS, secure payment processing, protection against common web vulnerabilities like XSS, CSRF, SQL injection).
*   **Performance:** Pages should load quickly to ensure a good user experience and improve SEO.
*   **SEO Friendliness:** URLs should be user-friendly and SEO-optimized. Basic meta tag management should be possible.

**5. Functional Requirements**

**5.1. Global & Homepage Features**
    *   **5.1.1. Pricing Toggle (Top of Page)**
        *   **Description:** A clearly visible toggle button at the top of all pages.
        *   **Functionality:** Allows users to switch product pricing display sitewide between "Excluding VAT" and "Including VAT."
        *   **Default:** TBD (To be decided, e.g., Ex VAT).
    *   **5.1.2. Navigation**
        *   Clear main navigation menu (e.g., Shop by Category, Samples, Promotions, Account, Contact).
        *   Footer navigation (e.g., About Us, T&Cs, Privacy Policy, Returns Policy, Contact).
    *   **5.1.3. Search Functionality**
        *   Prominent search bar.
        *   Search results page with product listings, sorting, and filtering options.
    *   **5.1.4. Promotional Banners (Homepage & Other Relevant Pages)**
        *   **Functionality:** Rotating/dynamic banners.
        *   **Content:**
            *   Current promotions.
            *   "Build a Bundle" discount offers.
            *   Special offers.
            *   Clearance items.
        *   Admin interface to manage banner content, images, links, and display order/duration.

**5.2. Product Catalog & Listings**
    *   **5.2.1. Category Pages**
        *   Display products within a specific category.
        *   Option for subcategories.
        *   Filtering options (e.g., by price, brand, attributes specific to the category).
        *   Sorting options (e.g., by price, popularity, newness).
    *   **5.2.2. Product Listing Pages (PLP)**
        *   Grid or list view for products.
        *   Display product image, name, price (reflecting VAT toggle), and "Add to Cart" / "View Product" button.
        *   Quick view option (optional).
    *   **5.2.3. Product Detail Pages (PDP)**
        *   Product name, multiple images/gallery, detailed description.
        *   Price (reflecting VAT toggle).
        *   SKU/Product Code.
        *   Stock availability.
        *   Quantity selector.
        *   "Add to Cart" button.
        *   "Request Sample" button (if applicable for the product).
        *   Product specifications/attributes.
        *   Customer reviews and ratings section.
        *   Related products/upsell/cross-sell section.

**5.3. Product Sample Request System (Reference: Cups Direct)**
    *   **5.3.1. Dedicated Sample Request Page**
        *   Clearly displays product categories from which samples can be requested.
        *   Users can browse or search for products eligible for samples.
    *   **5.3.2. Multi-Select Functionality**
        *   Users can select multiple products for samples, potentially across different categories, up to a defined limit (TBD).
    *   **5.3.3. Sample Request Flow**
        *   **Selection:** User adds desired samples to a "Sample Basket."
        *   **Shipping Details:** User provides shipping information.
        *   **Shipping Payment:** User proceeds to a payment page *solely* for covering the shipping cost of samples. (Payment gateway integration needed).
        *   **Confirmation:** User receives an order confirmation for the sample request.
    *   **5.3.4. Admin Management**
        *   Ability to mark products as "eligible for samples."
        *   Ability to set limits on the number of samples per request.
        *   View and manage sample requests.

**5.4. Shopping Cart & Checkout**
    *   **5.4.1. Shopping Cart Page**
        *   Display items added, quantity, individual price, subtotal.
        *   Ability to update quantity or remove items.
        *   Display estimated shipping (if calculable at this stage).
        *   Promo code/voucher input field.
        *   Clear "Proceed to Checkout" button.
    *   **5.4.2. Checkout Process (Multi-step or Single Page)**
        *   Guest checkout option and Sign-in/Register option.
        *   Shipping address input/selection (for logged-in users).
        *   Billing address input/selection.
        *   Shipping method selection (with associated costs).
        *   Order summary (including items, taxes, shipping, total).
        *   Payment method selection (see 5.9 Payment Gateways).
        *   Order confirmation page.
    *   **5.4.3. Email Notifications**
        *   Order confirmation email.
        *   Shipping confirmation email (with tracking link, if available).
        *   Payment success/failure notifications.

**5.5. Customer Account Experience**
    *   **5.5.1. Sign-Up Flow**
        *   Standard registration form (Name, Email, Password).
        *   Option for newsletter subscription.
        *   Upon successful sign-up, redirect to the homepage shop.
        *   Display a promotional banner immediately after sign-up/first login on homepage: “Follow and Share [on Instagram] for £X Off” (See 5.11 Promotions).
    *   **5.5.2. Login Flow**
        *   Standard email and password login.
        *   "Forgot Password" functionality.
    *   **5.5.3. Post-Login Dashboard**
        *   **Overview:** Potentially a summary of recent activity, loyalty points.
        *   **Previous Orders:**
            *   List of past orders with date, order number, total amount, status.
            *   View order details.
            *   "Reorder" button to quickly add items from a past order to the current cart.
            *   "Return" button on past orders (See 5.10 Returns System).
        *   **Personal Details & Saved Addresses:**
            *   View and edit name, email, password.
            *   Manage multiple saved shipping and billing addresses.
        *   **Order Tracking:**
            *   Display tracking information for shipped orders.
            *   Requires integration with shipping provider(s) (Discuss with Chris).
        *   **Loyalty Program / Rewards:**
            *   Display current tier, points balance, outstanding rewards.
            *   Information on how to earn more points/reach next tier.
        *   **Recommendations:**
            *   Display "Best Sellers" section.
            *   Display "Bundle Recommendations" (potentially personalized).

**5.6. Reward System (Tiered Loyalty Program - Inspiration: Tesco Clubcard)**
    *   **5.6.1. Basic Reward System**
        *   Customers earn points upon signing up.
        *   Customers earn points for every purchase (e.g., X points per £1 spent).
        *   System to convert points into redeemable rewards (e.g., vouchers, discounts).
        *   Display outstanding rewards to the customer in their account dashboard and potentially via email reminders.
    *   **5.6.2. Tier Levels (based on monthly spend)**
        *   **Bronze:** £500 monthly spend → X% off future purchases.
        *   **Silver:** £1,000 monthly spend → Y% off future purchases (Y > X).
        *   **Gold:** £3,000 monthly spend → Z% off future purchases (Z > Y).
        *   **Platinum:** £10,000 monthly spend → W% off future purchases (W > Z) + exclusive gifts/offers.
        *   Percentages (X, Y, Z, W) and specific gifts TBD.
    *   **5.6.3. Tier Management**
        *   System to track monthly customer spend.
        *   Automatic tier assignment/adjustment based on spend.
        *   Clear communication to customers about their tier status and benefits.
        *   Define how tier benefits are applied (e.g., automatic discount at checkout, unique coupon codes).

**5.7. Customer Service / Support System**
    *   **5.7.1. Issue Categories (for triage and reporting)**
        *   Delayed delivery
        *   Damaged items
        *   Incorrect or missing items
        *   Not received despite marked "delivered"
        *   Product quality concerns
        *   (Other categories as needed, e.g., account query, payment query)
    *   **5.7.2. Support System Implementation**
        *   **Chatbot/AI Assistant (Phase 1 - Triage):**
            *   Implement a chatbot to handle initial customer interactions.
            *   Guides users through predefined flows based on issue categories.
            *   Aims to resolve common queries or collect necessary information before escalation.
            *   (See 5.8 Chatbot Features)
        *   **Live Agent Escalation (Phase 2):**
            *   If the chatbot cannot resolve the issue, provide an option to escalate to a live agent.
            *   Contact Richard for live agent integration options and platform choices.
        *   **Contact Form / Email Support:** Standard contact form that routes to a support email address.
        *   **FAQ Page:** Comprehensive FAQ section covering common questions.

**5.8. Chatbot Features (To be configured by Richard/Developer)**
    *   **5.8.1. Intro Prompt:** "What can we help you with today?" (or similar).
    *   **5.8.2. Selectable Reasons (Main Menu Options):**
        *   Report a fault (with an order/product)
        *   Track my order
        *   Update delivery address (for an unshipped order - requires logic to check order status)
        *   Branding enquiry (e.g., custom branding on products)
        *   Product information
        *   Returns
        *   Account issues
        *   [Additional options TBD]
    *   **5.8.3. Conditional Logic:** Chatbot flows should guide users based on their selections, potentially asking clarifying questions.
    *   **5.8.4. Information Gathering:** For issues like "Report a fault," the chatbot should gather relevant details (order number, product affected, description of fault, photo upload option).
    *   **5.8.5. Integration:** Capable of basic lookups (e.g., order status via API if possible) and handoff to live agent system.

**5.9. Payment Gateways & Credit Accounts**
    *   **5.9.1. Standard Payment Gateways**
        *   **PayPal:** Full integration.
        *   **Other(s):** Research and integrate at least one other major card processor (e.g., Stripe, Braintree, Worldpay). Decision TBD.
    *   **5.9.2. Credit Account Functionality (for approved B2B or high-value B2C customers)**
        *   **Admin Approval:** Mechanism for admin to approve customers for credit accounts.
        *   **Checkout Option:** Approved customers see "Pay on Account" as a checkout option.
        *   **Invoicing System:**
            *   Generate invoices for orders placed on credit.
            *   Automatically email invoices to customers.
            *   Invoices to include an itemized list, total due, due date, and payment instructions.
            *   **Embedded Payment Gateway Button:** Invoices (PDF/HTML email) should contain a "Pay Now" button linking to a secure payment page for that specific invoice (pre-filled amount).
        *   **Automation:**
            *   Automated email reminders for overdue payments (e.g., 3 days before due, on due date, 7 days overdue, 14 days overdue).
            *   Internal notification system for admin/finance for unpaid invoices after X days (e.g., 30 days overdue).
        *   **Customer Account View:** Customers with credit accounts can see their invoice history, outstanding balances, and payment due dates in their account dashboard.

**5.10. Returns System (Inspiration: Nisbets / Amazon)**
    *   **5.10.1. Initiation Options**
        *   **Online Return Form:** A dedicated page/form where customers can initiate a return by providing order number, items to return, reason for return.
        *   **"Return" Button on Past Orders:** Within the customer's order history, a "Return" button next to eligible items/orders.
    *   **5.10.2. Return Process**
        *   Customer submits return request.
        *   Admin review/approval (optional, or automated for certain reasons).
        *   Customer receives return instructions (e.g., return address, RMA number if used).
        *   Customer ships item back.
        *   Admin receives and inspects returned item.
        *   Admin processes refund/exchange.
    *   **5.10.3. Return Terms (to be clearly stated on a Returns Policy page)**
        *   **Restocking Fee:** X% restocking fee may apply (details TBD, configurable per product/reason).
        *   **Return Window:** 30-day return window from date of delivery.
        *   **Overseas Customers:** Responsible for covering return shipping costs.
        *   **Condition of Goods:** Specify conditions for accepting returns (e.g., unused, original packaging).
    *   **5.10.4. Admin Management**
        *   View and manage return requests.
        *   Update return status (e.g., awaiting item, item received, refund processed).
        *   Issue refunds (integrated with payment gateway if possible).

**5.11. Promotions & Marketing**
    *   **5.11.1. Follow & Share Promo**
        *   **Offer:** £X off their next order for following the company on Instagram and/or sharing a specific post.
        *   **Validation:**
            *   Developer to explore options for validating shares/follows. This can be challenging.
            *   Potential options: Manual verification, asking for screenshot, unique code revealed after action (if platform allows), or trust-based with manual spot-checks.
            *   Consider simpler alternatives if validation is too complex (e.g., "Enter your Instagram handle for a chance to win/receive code").
        *   **Redemption:** Provide a unique discount code upon successful validation/submission.
    *   **5.11.2. Review Incentives**
        *   **Offer:** £X voucher for leaving a Google Review for the business.
        *   **Validation:** Customer provides link/screenshot of their review, or admin periodically checks new reviews.
        *   **Redemption:** Manually or semi-automatically issue a voucher code.
    *   **5.11.3. General Discount/Voucher System**
        *   Admin ability to create discount codes (percentage off, fixed amount off, free shipping).
        *   Ability to set conditions for codes (e.g., minimum spend, specific products/categories, usage limits, expiry dates).
    *   **5.11.4. "Build a Bundle" Discount**
        *   Allow customers to select multiple predefined products to create a bundle and receive a special discount.
        *   Admin interface to define eligible bundle products and the discount applied.

**5.12. Admin Backend Features**
    *   **5.12.1. Dashboard:** Overview of sales, orders, customers, etc.
    *   **5.12.2. Product Management:**
        *   Add/edit/delete products and categories.
        *   Manage product details (name, description, SKU, images, price, stock, attributes).
        *   Manage sample eligibility.
    *   **5.12.3. Order Management:**
        *   View, search, and filter orders.
        *   Update order status (e.g., pending, processing, shipped, delivered, cancelled, refunded).
        *   Process refunds.
        *   Manage sample requests.
    *   **5.12.4. Customer Management:**
        *   View and manage customer accounts.
        *   Manage credit account status and limits.
        *   View customer order history and loyalty status.
    *   **5.12.5. Promotions Management:**
        *   Create and manage discount codes and vouchers.
        *   Manage "Build a Bundle" offers.
        *   Manage rotating promo banners.
    *   **5.12.6. Loyalty Program Management:**
        *   Configure point earning rules and tier benefits.
        *   View customer tiers and points.
        *   Manually adjust points/rewards if necessary.
    *   **5.12.7. Content Management (Basic CMS):**
        *   Ability to edit static pages (e.g., About Us, Contact Us, T&Cs, Privacy Policy, Returns Policy, FAQ).
    *   **5.12.8. Reporting:** Basic sales reports, customer reports, product performance.

**6. Non-Functional Requirements**
*   **Usability:** Intuitive and easy-to-navigate interface for all user types (customer & admin).
*   **Performance:** Pages should load within 3 seconds on a standard connection.
*   **Scalability:** The system should be able to handle a growing number of products, customers, and orders.
*   **Reliability:** High uptime and availability.
*   **Maintainability:** Code should be well-structured, commented, and follow Rails best practices for ease of future development and maintenance.
*   **Accessibility:** Strive to meet WCAG 2.1 Level AA guidelines where feasible.
*   **Browser Compatibility:** Support for latest versions of major browsers (Chrome, Firefox, Safari, Edge).

**7. Assumptions**
*   Product information (descriptions, images, pricing, SKUs) will be provided.
*   Content for static pages (About Us, T&Cs, etc.) will be provided.
*   Branding guidelines (logo, color scheme) will be provided.
*   Decisions on "X%" and "£X" values for discounts, fees, and rewards will be finalized during development or by the client.
*   Chris will provide details/APIs for order tracking integration.
*   Richard will advise on live agent system selection and integration.
*   Research for "Other" payment gateways will be conducted and a decision made.

**8. Out of Scope (For Initial Launch - May be Future Enhancements)**
*   Mobile applications (iOS/Android).
*   Advanced AI-driven personalization beyond best-seller/bundle recommendations.
*   Multi-language/multi-currency beyond GBP.
*   Complex B2B portal features beyond credit accounts.
*   Marketplace functionality (multiple sellers).
*   Subscription-based products (unless "Build a Bundle" implies this).

**9. Success Metrics (Examples)**
*   Conversion Rate (Visits to Sales).
*   Average Order Value (AOV).
*   Customer Acquisition Cost (CAC).
*   Customer Lifetime Value (CLV).
*   Loyalty program engagement (sign-ups, tier progression).
*   Sample request conversion to full order.
*   Cart abandonment rate.
*   Customer support resolution time & satisfaction.

---

This PRD provides a comprehensive foundation. As development progresses, specific details (like the exact percentages for loyalty tiers or the specific "other" payment gateway) will be filled in. Remember to version control this document and update it as requirements evolve.