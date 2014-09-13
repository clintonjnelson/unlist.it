class Admin::CategoriesController < AdminController
  before_action :set_category, only: [:edit, :update, :destroy]

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = "Category #{@category.name} created."
      redirect_to new_admin_condition_path
    else
      flash.now[:error] = "Invalid name. See errors below."
      render 'new'
    end
  end

  def index
    @categories = Category.all
  end

  def edit
  end

  def update
    if @category.update(category_params)
      flash[:success] = "Category updated."
      redirect_to admin_categories_path
    else
      flash[:error] = "Please fix errors & try again."
      render 'edit'
    end
  end

  def destroy
    @category.destroy
    flash[:success] = "Category '#{@category.name}' & its Conditions deleted."
    redirect_to admin_categories_path
  end

  private
  def set_category
    @category = Category.find_by(slug: params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
