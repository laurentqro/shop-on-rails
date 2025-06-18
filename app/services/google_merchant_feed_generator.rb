class GoogleMerchantFeedGenerator
  def initialize(products = Product.includes(:category, :active_variants, image_attachment: :blob))
    @products = products
  end

  def generate_xml
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.rss(version: "2.0", "xmlns:g" => "http://base.google.com/ns/1.0") do
        xml.channel do
          xml.title "Afida Product Feed"
          xml.description "Afida Product Feed for Google Merchant Center"
          xml.link Rails.application.routes.url_helpers.shop_url

          @products.each do |product|
            generate_product_variants(xml, product)
          end
        end
      end
    end

    builder.to_xml
  end

  private

  def generate_product_variants(xml, product)
    product.active_variants.each do |variant|
      xml.item do
        # Required fields
        xml["g"].id variant.sku
        xml["g"].title variant.full_name
        xml["g"].description product.description || ""
        xml["g"].link Rails.application.routes.url_helpers.product_url(product, variant_id: variant.id)
        xml["g"].image_link variant_image_url(variant, product)
        xml["g"].availability variant.in_stock? ? "in_stock" : "out_of_stock"
        xml["g"].price "#{variant.price} GBP"
        xml["g"].unit_pricing_measure "#{variant.pac_size}ct"

        # Category
        xml["g"].product_type product.category.name if product.category

        # Brand (you might want to add this to your product model)
        xml["g"].brand "Afida"

        # Product identifiers
        xml["g"].gtin variant.gtin if variant.respond_to?(:gtin) && variant.gtin.present?
        xml["g"].mpn variant.sku

        # Condition
        xml["g"].condition "new"

        # Variant attributes
        if product.active_variants.count > 1
          xml["g"].item_group_id generate_item_group_id(product)

          # Add size if present
          if variant.volume_in_ml.present?
            xml["g"].size "#{variant.volume_in_ml}ml"
          elsif variant.name.match(/(\d+["']|\d+\s*inch)/i)
            xml["g"].size variant.name
          elsif variant.pac_size.present?
            xml["g"].size "Pack of #{variant.pac_size}"
          end
        end

        # Color stays with product, not variant
        xml["g"].color product.colour if product.colour.present?

        # Material
        xml["g"].material product.material if product.material.present?

        # Shipping (you'll need to configure this)
        xml["g"].shipping do
          xml["g"].country "GB"
          xml["g"].service "Standard"
          xml["g"].price "5.00 GBP"
        end
      end
    end
  end

  def generate_item_group_id(product)
    # Use base_sku if available, otherwise use product id
    product.base_sku || "PROD-#{product.id}"
  end

  def variant_image_url(variant, product)
    image = variant.image.attached? ? variant.image : product.image
    return "" unless image&.attached?

    Rails.application.routes.url_helpers.url_for(image)
  end
end
