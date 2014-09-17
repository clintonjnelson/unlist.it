class PagesController < ApplicationController

  def contact
    @message = Message.new
  end

  def browse
    @categories = Category.order('name ASC').all
  end

  def home
  end
end
