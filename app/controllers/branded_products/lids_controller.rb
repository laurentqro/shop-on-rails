module BrandedProducts
  class LidsController < ApplicationController
    include ProductHelper
    allow_unauthenticated_access

    def compatible_lids
      cup_size = params[:size]
      lids = compatible_lids_for_cup(cup_size)

      render json: {
        lids: lids.map { |lid|
          variant = lid.active_variants.first
          {
            id: lid.id,
            name: lid.name,
            slug: lid.slug,
            image_url: lid.image.attached? ? url_for(lid.image.variant(resize_to_limit: [ 200, 200 ])) : nil,
            price: variant&.price || 0,
            pac_size: variant&.pac_size || 1000,
            sku: variant&.sku,
            variant_id: variant&.id
          }
        }
      }
    end
  end
end
