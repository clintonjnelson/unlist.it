class RobotsController < ApplicationController
  layout false

  def index
    if Rails.env.production? && (request.host.include?('unlist'))
      render 'allow'
    else
      render 'disallow'
    end
  end
end
