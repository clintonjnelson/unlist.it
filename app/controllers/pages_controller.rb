class PagesController < ApplicationController

  def browse
    @categories = Category.order('name ASC').all
  end

  def home
  end
end
