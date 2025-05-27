class PagesController < ApplicationController
  def home
    @featured_products = Product.featured.limit(4)
    @categories = Category.all
  end

  def shop
    @products = Product.all
  end

  def branding
  end

  def samples
  end
end
