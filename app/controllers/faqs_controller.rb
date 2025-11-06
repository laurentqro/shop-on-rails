# frozen_string_literal: true

class FaqsController < ApplicationController
  allow_unauthenticated_access

  def index
    @categories = FaqService.all_categories
    @search_query = params[:q]
    @search_results = FaqService.search(@search_query) if @search_query.present?
  end
end
