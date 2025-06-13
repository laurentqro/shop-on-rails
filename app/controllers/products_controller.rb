class ProductsController < ApplicationController
  allow_unauthenticated_access

  def index
    @products = Product.includes(:category, :active_variants, image_attachment: :blob).all
  end

  def show
    @product = Product.includes(:active_variants, :category).find_by!(slug: params[:id])

    @selected_variant = if params[:variant_id].present?
      @product.active_variants.find_by(id: params[:variant_id])
    end

    @selected_variant ||= @product.default_variant

    # Redirect if no variants available
    unless @selected_variant
      redirect_to products_path, alert: "This product is currently unavailable."
    end
  end
end
