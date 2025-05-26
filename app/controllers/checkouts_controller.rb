class CheckoutsController < ApplicationController

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
        quantity: item.quantity,
        tax_rates: [tax_rate.id]
      }
    end

    begin
      session = Stripe::Checkout::Session.create({
        payment_method_types: ["card"],
        line_items: line_items,
        mode: "payment",
        shipping_address_collection: {
          allowed_countries: ["GB"]
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
        success_url: success_checkout_url,
        cancel_url: cancel_checkout_url
      })

      redirect_to session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      flash[:error] = e.message
      redirect_to cart_path
    end
  end

  def success
    redirect_to root_path, notice: "Payment successful!"
  end

  def cancel
    redirect_to cart_path
  end

  private

  def tax_rate
    @tax_rate ||= Stripe::TaxRate.create({
      display_name: "VAT",
      percentage: 20,
      country: "GB",
      jurisdiction: "United Kingdom",
      description: "Value Added Tax",
      inclusive: false
    })
  end
end