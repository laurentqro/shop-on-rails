module BrandedProducts
  class ConfiguratorController < ApplicationController
    allow_unauthenticated_access

    def calculate_price
      product = Product.find_by(id: params[:product_id])
      return render json: { success: false, error: "Product not found" }, status: :bad_request unless product

      service = BrandedProductPricingService.new(product)
      result = service.calculate(
        size: params[:size],
        quantity: params[:quantity]&.to_i
      )

      if result.success?
        render json: {
          success: true,
          price_per_unit: result.price_per_unit,
          total_price: result.total_price,
          quantity: result.quantity,
          case_quantity: result.case_quantity,
          cases_needed: result.cases_needed
        }
      else
        render json: {
          success: false,
          error: result.error
        }, status: :unprocessable_entity
      end
    end

    def available_options
      product = Product.find(params[:product_id])
      service = BrandedProductPricingService.new(product)

      sizes = service.available_sizes
      quantity_tiers = {}

      sizes.each do |size|
        quantity_tiers[size] = service.available_quantities(size)
      end

      render json: {
        sizes: sizes,
        quantity_tiers: quantity_tiers
      }
    end
  end
end
