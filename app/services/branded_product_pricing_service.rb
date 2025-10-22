class BrandedProductPricingService
  Result = Struct.new(:success, :price_per_unit, :total_price, :quantity, :case_quantity, :cases_needed, :error, keyword_init: true) do
    def success?
      success
    end
  end

  MINIMUM_ORDER_QUANTITY = 1000

  def initialize(product)
    @product = product
  end

  def calculate(size:, quantity:)
    return error_result("Size and quantity are required") if size.blank? || quantity.blank?
    return error_result("Quantity below minimum order") if quantity < MINIMUM_ORDER_QUANTITY

    pricing = BrandedProductPrice.find_for_configuration(@product, size, quantity)
    return error_result("No pricing found for this configuration") unless pricing

    Result.new(
      success: true,
      price_per_unit: pricing.price_per_unit,
      total_price: pricing.price_per_unit * quantity,
      quantity: quantity,
      case_quantity: pricing.case_quantity,
      cases_needed: (quantity.to_f / pricing.case_quantity).ceil
    )
  end

  def available_sizes
    @product.branded_product_prices.distinct.pluck(:size).sort
  end

  def available_quantities(size)
    @product.branded_product_prices
            .where(size: size)
            .pluck(:quantity_tier)
            .sort
  end

  private

  def error_result(message)
    Result.new(success: false, error: message)
  end
end
