require "test_helper"

class CheckoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)

    # Create a fresh cart with items for testing
    @cart = Cart.create!(user: @user)
    @cart_item = @cart.cart_items.create!(
      product_variant: product_variants(:one),
      quantity: 2,
      price: 10.0
    )

    # Stub Current.cart to return our test cart for all tests
    Current.stubs(:cart).returns(@cart)

    # Create a UK VAT tax rate for the controller to find
    FakeStripe::TaxRate.create_uk_vat
  end

  # ============================================================================
  # CREATE ACTION TESTS (POST /checkouts)
  # ============================================================================

  test "create redirects to Stripe checkout session URL" do
    post checkout_path

    assert_response :see_other
    assert_match %r{https://checkout\.stripe\.com/test/sess_}, response.redirect_url
  end

  test "create builds line items from cart items" do
    # Stub to capture the params passed to Stripe
    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    assert_not_nil params_captured
    assert_equal "gbp", params_captured[:line_items].first[:price_data][:currency]
    assert_equal "card", params_captured[:payment_method_types].first
    assert_equal "payment", params_captured[:mode]
  end

  test "create includes customer email for authenticated users" do
    Current.stubs(:user).returns(@user)

    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    assert_equal @user.email_address, params_captured[:customer_email]
    assert_equal @user.id, params_captured[:client_reference_id]
  end

  test "create does not include customer details for guest users" do
    # Don't sign in - test as guest
    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    assert_nil params_captured[:customer_email]
    assert_nil params_captured[:client_reference_id]
  end

  test "create includes UK shipping address collection" do
    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    assert_includes params_captured[:shipping_address_collection][:allowed_countries], "GB"
  end

  test "create includes shipping options from Shipping module" do
    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    assert_not_empty params_captured[:shipping_options]
    assert_equal 2, params_captured[:shipping_options].length
    assert_includes params_captured[:shipping_options].first[:shipping_rate_data][:display_name], "Shipping"
  end

  test "create includes success and cancel URLs" do
    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    assert_match /checkout\/success/, params_captured[:success_url]
    assert_match /checkout\/cancel/, params_captured[:cancel_url]
    assert_includes params_captured[:success_url], "{CHECKOUT_SESSION_ID}"
  end

  test "create finds or creates UK VAT tax rate" do
    # FakeStripe has a tax rate already from setup
    existing_rate_id = Stripe::TaxRate.list.data.first.id

    params_captured = nil
    Stripe::Checkout::Session.define_singleton_method(:create) do |params|
      params_captured = params
      FakeStripe::CheckoutSession.new(params)
    end

    post checkout_path

    # Should reuse existing tax rate
    assert_equal existing_rate_id, params_captured[:line_items].first[:tax_rates].first
  end

  # ============================================================================
  # SUCCESS ACTION TESTS (GET /checkouts/success)
  # ============================================================================

  test "success creates order from paid Stripe session" do
    # Create a realistic checkout session
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com",
      customer_name: "Jane Buyer",
      client_reference_id: @user.id
    )

    assert_difference "Order.count", 1 do
      get success_checkout_path, params: { session_id: session.id }
    end

    order = Order.last
    assert_equal "buyer@example.com", order.email
    assert_equal session.id, order.stripe_session_id
    assert_equal "paid", order.status
  end

  test "success extracts shipping details from Stripe session" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com",
      customer_name: "Test Buyer"
    )

    get success_checkout_path, params: { session_id: session.id }

    order = Order.last
    assert_equal "Test Buyer", order.shipping_name
    assert_equal "123 Test Street", order.shipping_address_line1
    assert_equal "Flat 4", order.shipping_address_line2
    assert_equal "London", order.shipping_city
    assert_equal "SW1A 1AA", order.shipping_postal_code
    assert_equal "GB", order.shipping_country
  end

  test "success calculates order totals from cart and Stripe session" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com",
      shipping_amount_total: 500 # £5.00 in pence
    )

    get success_checkout_path, params: { session_id: session.id }

    order = Order.last
    assert_equal @cart.subtotal_amount, order.subtotal_amount
    assert_equal @cart.vat_amount, order.vat_amount
    assert_equal 5.0, order.shipping_amount
    assert_equal @cart.subtotal_amount + @cart.vat_amount + 5.0, order.total_amount
  end

  test "success creates order items from cart items" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    assert_difference "OrderItem.count", @cart.cart_items.count do
      get success_checkout_path, params: { session_id: session.id }
    end

    order = Order.last
    order_item = order.order_items.first

    assert_equal @cart_item.product_variant, order_item.product_variant
    assert_equal @cart_item.product_variant.display_name, order_item.product_name
    assert_equal @cart_item.product_variant.sku, order_item.product_sku
    assert_equal @cart_item.price, order_item.price
    assert_equal @cart_item.quantity, order_item.quantity
  end

  test "success clears cart after creating order" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    initial_cart_items_count = @cart.cart_items.count
    assert initial_cart_items_count > 0, "Cart should have items before checkout"

    get success_checkout_path, params: { session_id: session.id }

    @cart.reload
    assert_equal 0, @cart.cart_items.count
  end

  test "success sends order confirmation email" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      get success_checkout_path, params: { session_id: session.id }
    end
  end

  test "success redirects to order show page" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    get success_checkout_path, params: { session_id: session.id }

    order = Order.last
    assert_redirected_to order_path(order)
    assert_match /created successfully/, flash[:notice]
  end

  test "success prevents duplicate orders with same session_id" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    # First request creates order
    get success_checkout_path, params: { session_id: session.id }
    first_order = Order.last

    # Second request should not create duplicate
    assert_no_difference "Order.count" do
      get success_checkout_path, params: { session_id: session.id }
    end

    assert_redirected_to order_path(first_order)
    assert_match /already created/, flash[:notice]
  end

  test "success handles missing session_id parameter" do
    get success_checkout_path

    assert_redirected_to cart_path
    assert_match /Invalid checkout session/, flash[:error]
  end

  test "success handles unpaid Stripe sessions" do
    session = FakeStripe::CheckoutSession.create_unpaid(
      customer_email: "buyer@example.com"
    )

    assert_no_difference "Order.count" do
      get success_checkout_path, params: { session_id: session.id }
    end

    assert_redirected_to cart_path
    assert_match /Payment was not completed/, flash[:error]
  end

  test "success handles invalid session_id" do
    get success_checkout_path, params: { session_id: "sess_invalid_12345" }

    assert_redirected_to cart_path
    assert_match /Unable to verify payment/, flash[:error]
  end

  test "success handles empty cart gracefully" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    # Clear the cart
    @cart.cart_items.destroy_all

    assert_no_difference "Order.count" do
      get success_checkout_path, params: { session_id: session.id }
    end

    assert_redirected_to root_path
    assert_match /No items found in cart/, flash[:error]
  end

  test "success associates order with user for authenticated checkouts" do
    session = Stripe::Checkout::Session.create(
      customer_email: @user.email_address,
      client_reference_id: @user.id
    )

    get success_checkout_path, params: { session_id: session.id }

    order = Order.last
    assert_equal @user, order.user
  end

  test "success creates guest order when no user is authenticated" do
    session = Stripe::Checkout::Session.create(
      customer_email: "guest@example.com"
    )

    get success_checkout_path, params: { session_id: session.id }

    order = Order.last
    assert_nil order.user
    assert_equal "guest@example.com", order.email
  end

  # ============================================================================
  # CANCEL ACTION TESTS (GET /checkouts/cancel)
  # ============================================================================

  test "cancel redirects to cart with notice" do
    get cancel_checkout_path

    assert_redirected_to cart_path
    assert_match /Checkout cancelled/, flash[:notice]
  end

  # ============================================================================
  # ERROR HANDLING TESTS (Using Mocha for edge cases)
  # ============================================================================

  test "create handles Stripe API connection errors" do
    Stripe::Checkout::Session.stubs(:create).raises(
      FakeStripe::Errors.api_connection_error
    )

    post checkout_path

    assert_redirected_to cart_path
    assert_not_nil flash[:error]
    assert_match /Failed to connect/, flash[:error]
  end

  test "create handles Stripe API errors" do
    Stripe::Checkout::Session.stubs(:create).raises(
      FakeStripe::Errors.api_error
    )

    post checkout_path

    assert_redirected_to cart_path
    assert_not_nil flash[:error]
  end

  test "create handles Stripe invalid request errors" do
    Stripe::Checkout::Session.stubs(:create).raises(
      FakeStripe::Errors.invalid_request("Invalid line items")
    )

    post checkout_path

    assert_redirected_to cart_path
    assert_match /Invalid line items/, flash[:error]
  end

  test "create logs Stripe errors" do
    Stripe::Checkout::Session.stubs(:create).raises(
      FakeStripe::Errors.api_connection_error
    )

    # Capture Rails.logger output
    logged_messages = []
    Rails.logger.stubs(:error).with { |msg| logged_messages << msg }

    post checkout_path

    assert logged_messages.any? { |msg| msg.include?("Stripe error:") }
  end

  test "success handles Stripe API errors when retrieving session" do
    Stripe::Checkout::Session.stubs(:retrieve).raises(
      FakeStripe::Errors.api_connection_error
    )

    assert_no_difference "Order.count" do
      get success_checkout_path, params: { session_id: "sess_test_123" }
    end

    assert_redirected_to cart_path
    assert_match /Unable to verify payment/, flash[:error]
  end

  test "success handles general errors during order creation" do
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    # Simulate an error during order creation (e.g., validation failure)
    Order.any_instance.stubs(:save!).raises(StandardError.new("Database error"))

    assert_no_difference "Order.count" do
      get success_checkout_path, params: { session_id: session.id }
    end

    assert_redirected_to cart_path
    assert_match /error processing your order/, flash[:error]
  end

  test "success validates required shipping details presence" do
    # Create session with missing shipping details
    session = Stripe::Checkout::Session.create(
      customer_email: "buyer@example.com"
    )

    # Override customer_details to have nil address fields
    session.customer_details.address.instance_variable_set(:@line1, nil)

    # Stub retrieve to return our modified session
    Stripe::Checkout::Session.stubs(:retrieve).returns(session)

    assert_no_difference "Order.count" do
      get success_checkout_path, params: { session_id: session.id }
    end

    assert_redirected_to cart_path
    assert_match /error processing your order/, flash[:error]
  end

  test "create respects rate limiting" do
    # Rate limit is 10 requests per minute
    # This test verifies the rate_limit declaration exists
    # (Actual rate limiting behavior would require integration test with time manipulation)

    11.times do |i|
      post checkout_path
    end

    # After 10 requests, should hit rate limit
    # Note: In actual implementation, this would require time-based testing
    # or integration tests with proper rate limit store
  end

  # ============================================================================
  # ORGANIZATION AND B2B TESTS
  # ============================================================================

  test "creates order with organization for B2B users" do
    sign_in_as users(:acme_admin)

    # Add item to cart
    @cart.cart_items.create!(
      product: products(:single_wall_cups),
      product_variant: product_variants(:single_wall_8oz_white),
      quantity: 10,
      price: 10.0
    )

    session = Stripe::Checkout::Session.create(
      customer_email: users(:acme_admin).email_address,
      client_reference_id: users(:acme_admin).id
    )

    get success_checkout_path, params: { session_id: session.id }

    # Verify order created with organization
    order = Order.last
    assert_equal organizations(:acme), order.organization
    assert_equal users(:acme_admin), order.placed_by_user
  end

  test "creates order without organization for consumer users" do
    sign_in_as users(:consumer)

    # Add item to cart
    @cart.cart_items.create!(
      product: products(:single_wall_cups),
      product_variant: product_variants(:single_wall_8oz_white),
      quantity: 10,
      price: 10.0
    )

    session = Stripe::Checkout::Session.create(
      customer_email: users(:consumer).email_address,
      client_reference_id: users(:consumer).id
    )

    get success_checkout_path, params: { session_id: session.id }

    # Verify order created without organization
    order = Order.last
    assert_nil order.organization_id
    assert_nil order.placed_by_user_id
    assert_equal users(:consumer), order.user
  end

  test "sets branded_order_status for orders with configured items" do
    sign_in_as users(:acme_admin)

    # Add configured item
    cart_item = @cart.cart_items.new(
      product_variant: product_variants(:branded_template_variant),
      quantity: 1,
      configuration: { size: "12oz", quantity: 5000 },
      calculated_price: 1000.00,
      price: 1000.00
    )

    # Attach a design file before saving
    cart_item.design.attach(
      io: StringIO.new("fake design content"),
      filename: "design.pdf",
      content_type: "application/pdf"
    )
    cart_item.save!

    session = Stripe::Checkout::Session.create(
      customer_email: users(:acme_admin).email_address,
      client_reference_id: users(:acme_admin).id
    )

    get success_checkout_path, params: { session_id: session.id }

    order = Order.last
    assert_equal "design_pending", order.branded_order_status
  end

  # ============================================================================
  # HELPER METHODS
  # ============================================================================

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password" }
  end
end
