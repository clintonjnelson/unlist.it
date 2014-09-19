class Admin::ConditionsController < AdminController
  before_action :set_condition, only: [:edit, :update, :destroy]


  ############################### CRUD ACTIONS #################################
  def new
    @condition = Condition.new
  end

  def create
    @category = Category.find(params[:condition][:category_id])
    @add      = ConditionsManager.new(@category).add_or_update_condition(condition_params, params["conditions"])
    if @add
      flash[:success] = "Condition was successfully saved."
      redirect_to new_admin_condition_path
    else
      flash[:error] = "Please fix the form/order errors below & try again."
      redirect_to new_admin_condition_path
    end
  end

  def edit
    @other_conditions = @condition.other_conditions_for_category
  end

  def update
    @category = @condition.category
    @update   = ConditionsManager.new(@category).add_or_update_condition(condition_params, params["conditions"], params[:id])
    if @update
      flash[:success] = "Changes saved."
      redirect_to admin_categories_path
    else
      flash[:error] = "Please fix errors & try again."
      render 'edit'
    end
  end

  def destroy
    @condition.destroy
    flash[:success] = "Condition '#{@condition.level}' removed."
    redirect_to admin_categories_path
  end


  ############################## CUSTOM ACTIONS ################################
  def conditions_by_category
    @conditions = Condition.where(category_id: params[:category_id]).all
    respond_to do |format|
      format.js {render 'conditions_by_category'}
    end
  end


  ############################## Private Methods ###############################
  private
  def condition_params
    params.require(:condition).permit(:category_id, :level, :position)
  end

  def set_condition
    @condition = Condition.find(params[:id])
  end
end
