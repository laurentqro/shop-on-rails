class SitemapsController < ApplicationController
  allow_unauthenticated_access

  def show
    @sitemap_xml = SitemapGeneratorService.new.generate

    respond_to do |format|
      format.xml { render xml: @sitemap_xml }
    end
  end
end
