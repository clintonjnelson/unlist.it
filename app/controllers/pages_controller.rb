class PagesController < ApplicationController

  def browse
    @categories = Category.all
  end

  def home
    if session[:zipcode]
      @location = session[:zipcode]
    elsif request.remote_ip
      @loaction = request.remote_ip
    else
      @location = "Seattle, WA"
    end
  end
end
