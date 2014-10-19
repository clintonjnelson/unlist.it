class RobotsController < ApplicationController
  layout false

  def index
    host = request.host
    if Rails.env.production? && (host == ('unlist.it' || 'www.unlist.it'))
      render 'allow'
    else
      render 'disallow'
    end
  end
end
