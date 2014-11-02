class PagesController < ApplicationController

  def contact
    @message = Message.new
  end

  def browse
    @category   = "All"
    @categories = Category.order('name ASC').all
    @unlistings = Unlisting.order('created_at DESC').active.for_everyone.paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'pages/browse'         }
      format.js   { render 'pages/browse.js.haml' }
    end
  end

  def home

  end
end
