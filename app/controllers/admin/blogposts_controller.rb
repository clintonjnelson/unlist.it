class Admin::BlogpostsController < AdminController
  before_action :set_blogpost, only: [:edit, :update, :destroy]

  def new
    @blogpost = Blogpost.new
  end

  def create
    @blogpost = Blogpost.new(blogpost_params)
    if @blogpost.save
      flash[:success] = "Blogpost created."
      redirect_to blogposts_path
    else
      flash[:error]   = "Oops, please fix the errors & try again."
      render 'new'
    end
  end

  # def index
  #   @blogposts = Blogpost.order('created_at DESC').all
  # end

  def edit
  end

  def update
    if @blogpost && @blogpost.update(blogpost_params)
      flash[:success] = "Blogpost updated."
      redirect_to blogposts_path
    else
      flash[:error]   = "Oops, please fix the errors & try again."
      render 'edit'
    end
  end

  def destroy
    Blogpost.destroy(@blogpost.id)
    flash[:success] = "Blogpost deleted."
    redirect_to blogposts_path
  end


  private
  def blogpost_params
    params.require(:blogpost).permit(:id, :title, :content, :link, :blogpic)
  end

  def set_blogpost
    @blogpost = Blogpost.find_by(slug: params[:id])
  end
end
