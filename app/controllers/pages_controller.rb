class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @featured_products = Product.featured.limit(4)
    @categories = Category.with_attached_image.all
  end

  def shop
    @categories = Category.with_attached_image.order(:name)
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

  def terms_conditions
  end

  def privacy_policy
  end

  def cookies_policy
  end
end
