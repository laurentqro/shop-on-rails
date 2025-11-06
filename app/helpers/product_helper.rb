module ProductHelper
  def compatible_lids_for_cup(cup_size)
    return [] if cup_size.blank?

    # Find all products that list this cup size as compatible
    Product.where("? = ANY(compatible_cup_sizes)", cup_size)
           .where(product_type: "standard")
           .includes(:active_variants)
           .with_attached_product_photo
           .select { |product| product.active_variants.any? }
  end
end
