class CheckoutsController < ApplicationController
  allow_unauthenticated_access

  def create
    cart = Current.cart
    line_items = cart.cart_items.map do |item|
      {
        quantity: item.quantity,
        price_data: {
          currency: "gbp",
          product_data: {
            name: item.product.name
          },
          unit_amount: (item.price.to_f * 100).round,
          tax_behavior: "exclusive"
        },
        tax_rates: [ tax_rate.id ]
      }
    end

    begin
      session_params = {
        payment_method_types: [ "card" ],
        line_items: line_items,
        mode: "payment",
        shipping_address_collection: {
          allowed_countries: [ "GB" ]
        },
        shipping_options: [
          {
            shipping_rate_data: {
              type: "fixed_amount",
              fixed_amount: {
                amount: 500,
                currency: "gbp"
              },
              display_name: "Standard Shipping",
              delivery_estimate: {
                minimum: { unit: "business_day", value: 2 },
                maximum: { unit: "business_day", value: 3 }
              }
            }
          },
          {
            shipping_rate_data: {
              type: "fixed_amount",
              fixed_amount: {
                amount: 1000,
                currency: "gbp"
              },
              display_name: "Express Shipping",
              delivery_estimate: {
                minimum: { unit: "business_day", value: 1 },
                maximum: { unit: "business_day", value: 2 }
              }
            }
          }
        ],
        success_url: success_checkout_url + "?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: cancel_checkout_url
      }

      if Current.user
        session_params[:customer_email] = Current.user.email
        session_params[:client_reference_id] = Current.user.id
      end

      session = Stripe::Checkout::Session.create(session_params)

      redirect_to session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      flash[:error] = e.message
      redirect_to cart_path
    end
  end

  def success
    session_id = params[:session_id]

    unless session_id.present?
      flash[:error] = "Invalid checkout session"
      return redirect_to cart_path
    end

    begin
      stripe_session = Stripe::Checkout::Session.retrieve(session_id)

      unless stripe_session.payment_status == "paid"
        flash[:error] = "Payment was not completed successfully"
        return redirect_to cart_path
      end

      # Check if order already exists for this session (prevent duplicates)
      existing_order = Order.find_by(stripe_session_id: session_id)
      if existing_order
        flash[:notice] = "Order #{existing_order.display_number} was already created!"
        return redirect_to order_path(existing_order)
      end

      # Get the cart
      cart = Current.cart
      if cart.blank? || cart.cart_items.empty?
        flash[:error] = "No items found in cart"
        return redirect_to root_path
      end

      # Create the order
      customer_details = stripe_session.customer_details
      order = create_order_from_stripe_session(stripe_session, cart)

      # Clear the cart after successful order creation
      cart.cart_items.destroy_all

      # Send order confirmation email
      OrderMailer.with(order: order).confirmation_email.deliver_later

      flash[:notice] = "Order #{order.display_number} created successfully! Payment successful!"
      redirect_to order_path(order)

    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error in checkout success: #{e.message}")
      flash[:error] = "Unable to verify payment. Please contact support."
      redirect_to cart_path
    rescue => e
      Rails.logger.error("Error creating order: #{e.message}")
      flash[:error] = "There was an error processing your order. Please contact support."
      redirect_to cart_path
    end
  end

  def cancel
    redirect_to cart_path, notice: "Checkout cancelled."
  end

  private

  def create_order_from_stripe_session(stripe_session, cart)
    customer_details = stripe_session.customer_details
    # Calculate totals from cart
    subtotal = cart.subtotal_amount
    vat_amount = cart.vat_amount

    # Get shipping cost from Stripe session
    shipping_cost = if stripe_session.shipping_cost
      (stripe_session.shipping_cost.amount_total / 100.0).round(2)
    else
      0.0
    end

    total_amount = subtotal + vat_amount + shipping_cost

    # Handle shipping details - they might be null if not collected
    shipping_name = customer_details.name
    shipping_address_line1 = customer_details.address.line1
    shipping_address_line2 = customer_details.address.line2
    shipping_city = customer_details.address.city
    shipping_postal_code = customer_details.address.postal_code
    shipping_country = customer_details.address.country

    if [ shipping_name, shipping_address_line1, shipping_city, shipping_postal_code, shipping_country ].any?(&:blank?)
      raise "Shipping details are required"
    end

    # Create the order
    order = Order.create!(
      user: User.find_by(id: stripe_session.client_reference_id),
      email: customer_details.email,
      stripe_session_id: stripe_session.id,
      status: "paid",
      subtotal_amount: subtotal,
      vat_amount: vat_amount,
      shipping_amount: shipping_cost,
      total_amount: total_amount,
      shipping_name: shipping_name,
      shipping_address_line1: shipping_address_line1,
      shipping_address_line2: shipping_address_line2,
      shipping_city: shipping_city,
      shipping_postal_code: shipping_postal_code,
      shipping_country: shipping_country
    )

    # Create order items from cart items
    cart.cart_items.each do |cart_item|
      order.order_items.create!(
        product_variant: cart_item.product_variant,
        product_name: cart_item.product_variant.display_name,
        product_sku: cart_item.product_variant.sku,
        price: cart_item.price,
        quantity: cart_item.quantity,
        line_total: cart_item.subtotal_amount
      )
    end

    order
  end

  def tax_rate
    @tax_rate ||= begin
      # Try to find existing UK VAT tax rate to avoid creating duplicates
      existing_rates = Stripe::TaxRate.list(active: true, limit: 100)
      uk_vat_rate = existing_rates.data.find do |rate|
        rate.percentage == 20.0 &&
          rate.country == "GB" &&
          rate.inclusive == false
      end

      # Use existing rate if found, otherwise create new one
      uk_vat_rate || Stripe::TaxRate.create({
        display_name: "VAT",
        percentage: 20,
        country: "GB",
        jurisdiction: "United Kingdom",
        description: "Value Added Tax",
        inclusive: false
      })
    end
  end
end
