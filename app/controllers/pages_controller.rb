class PagesController < ApplicationController

  def browse
    @categories = Category.all
  end
end
