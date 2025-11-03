class CategoriesController < ApplicationController
  allow_unauthenticated_access

  def show
    @category = Category.find_by!(slug: params[:id])
    @products = @category.products.catalog_products.includes(:product_photo_attachment)
  end
end
