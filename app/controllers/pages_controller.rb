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

  def about
  end

  def contact
  end

  def terms
  end

  def privacy
  end

  def cookies_policy
  end
end
