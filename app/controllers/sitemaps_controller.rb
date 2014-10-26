class SitemapsController < ApplicationController
  layout false
  def show
    redirect_to "http://s3-us-west-2.amazonaws.com/#{ENV['PUBLIC_AWS_BUCKET']}/sitemaps/sitemap.xml.gz"
  end
end
