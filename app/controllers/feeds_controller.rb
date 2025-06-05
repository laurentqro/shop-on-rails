class FeedsController < ApplicationController
  allow_unauthenticated_access

  def google_merchant
    @products = Product.includes(:category, :active_variants, image_attachment: :blob)

    feed_generator = GoogleMerchantFeedGenerator.new(@products)

    respond_to do |format|
      format.xml { render xml: feed_generator.generate_xml }
    end
  end
end
