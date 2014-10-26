class SitemapsController < ApplicationController
  layout false
  def show
    redirect_to "http://s3.amazonaws.com/#{ENV['PUBLIC_AWS_BUCKET']}/sitemap.xml.gz"
  end
end
