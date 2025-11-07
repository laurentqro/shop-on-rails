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

  # Display product/variant photo with placeholder if missing
  # Usage: product_photo_tag(product.primary_photo, alt: "Product name", class: "w-20 h-20", data: { product_options_target: "imageDisplay" })
  def product_photo_tag(photo, options = {})
    css_class = options[:class] || "w-full h-full object-cover"
    alt_text = options[:alt] || "Product photo"
    variant_options = options[:variant] || { resize_to_limit: [ 400, 400 ] }
    data_attributes = options[:data] || {}

    if photo&.attached?
      image_tag photo.variant(variant_options), class: css_class, alt: alt_text, data: data_attributes
    else
      # Show placeholder SVG
      content_tag :div, { class: "#{css_class} bg-base-200 flex items-center justify-center", data: data_attributes } do
        content_tag :svg, xmlns: "http://www.w3.org/2000/svg", class: "h-1/2 w-1/2 text-base-content/20", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor" do
          tag.path stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
        end
      end
    end
  end
end
