class PagesController < ApplicationController

  def browse
    @categories = Category.order('name ASC').all
  end

  def home
    # if session[:zipcode]
    #   @location = session[:zipcode]
    # elsif request.remote_ip
    #   @location = request.remote_ip
    # else
    #   @location = "Seattle, WA"
    # end
  end
end
