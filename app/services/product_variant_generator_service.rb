class ProductVariantGeneratorService
  Result = Struct.new(:success, :variants_created, :error, keyword_init: true) do
    def success?
      success
    end
  end

  def initialize(product)
    @product = product
  end

  def generate_variants(base_price: nil, base_stock: 0, pricing: {})
    return error_result("Product must have options assigned") if @product.options.empty?

    combinations = generate_option_combinations
    variants_created = 0

    ActiveRecord::Base.transaction do
      combinations.each do |combination|
        # Skip if variant already exists
        next if variant_exists?(combination)

        # Get custom pricing or use base
        custom = pricing[combination] || {}
        price = custom[:price] || base_price
        stock = custom[:stock] || base_stock

        create_variant(combination, price, stock)
        variants_created += 1
      end
    end

    Result.new(success: true, variants_created: variants_created)
  rescue StandardError => e
    error_result("Failed to generate variants: #{e.message}")
  end

  private

  def generate_option_combinations
    option_values_by_option = @product.option_assignments.includes(product_option: :values).map do |assignment|
      [
        assignment.product_option.name,
        assignment.product_option.values.pluck(:value)
      ]
    end.to_h

    # Generate all combinations using Cartesian product
    option_names = option_values_by_option.keys
    value_arrays = option_values_by_option.values

    value_arrays.first.product(*value_arrays[1..-1]).map do |combo|
      combo = [combo] unless combo.is_a?(Array)
      Hash[option_names.zip(combo)]
    end
  end

  def variant_exists?(combination)
    @product.variants.where("option_values @> ?", combination.to_json).exists?
  end

  def create_variant(combination, price, stock)
    sku = generate_sku(combination)
    name = combination.values.join(" ")

    @product.variants.create!(
      sku: sku,
      name: name,
      price: price,
      stock_quantity: stock,
      option_values: combination,
      active: true
    )
  end

  def generate_sku(combination)
    base = @product.slug.upcase.gsub("-", "")
    suffix = combination.values.map { |v| v.gsub(/[^A-Z0-9]/i, "").upcase[0..2] }.join("-")
    "#{base}-#{suffix}"
  end

  def error_result(message)
    Result.new(success: false, error: message)
  end
end
