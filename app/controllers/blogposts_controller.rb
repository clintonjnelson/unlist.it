class BlogpostsController < ApplicationController
  def index
    #Paginate by showing the first 5 blogposts with standard pagination
    @blogposts = Blogpost.order('created_at DESC').all
  end
end
