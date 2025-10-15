class CategoriesController < ApplicationController
  allow_unauthenticated_access

  def show
    @category = Category.find_by!(slug: params[:id])
    @products = @category.products.includes(:image_attachment)
  end
end
