class Admin::ConditionsController < AdminController
  before_action :set_condition, only: [:edit, :update, :destroy]
  def new
    @condition = Condition.new
  end

  def create
    @category = Category.find(params[:condition][:category_id])
    if update_positions
      flash[:success] = "Condition was successfully saved."
      redirect_to admin_categories_path
    else
      flash[:error] = "Please fix the form/order errors below & try again."
      redirect_to new_admin_condition_path
    end
  end

  def edit
    @conditions = @condition.other_conditions_for_category
  end

  def update
    @category = @condition.category
    if update_positions
      flash[:success] = "Changes saved."
      redirect_to admin_categories_path
    else
      flash[:error] = "Please fix errors & try again."
      render 'edit'
    end
  end

  def conditions_by_category
    @conditions = Condition.where(category_id: params[:category_id]).all
    respond_to do |format|
      format.js {render 'conditions_by_category'}
    end
  end

  def destroy
    @condition.destroy
    flash[:success] = "Condition '#{@condition.level}' removed."
    redirect_to admin_categories_path
  end

  ###############Private Methods##############
  private
  def condition_params
    params.require(:condition).permit(:category_id, :level, :position)
  end

  def set_condition
    @condition = Condition.find(params[:id])
  end

  ########### CREATION METHODS - SEND TO SERVICE OBJECT ##############
  def update_positions
    begin
      update_position_transaction
      @category.reload.reorder_conditions
      return true
    rescue ActiveRecord::RecordInvalid
      return false
    end
  end

  def update_position_transaction
    ActiveRecord::Base.transaction do
      set_condition_positions_temporarily_to_nil
      make_or_update_condition
      attempt_to_update_positions_per_user_entries unless params["conditions"].blank?
    end
  end

  def set_condition_positions_temporarily_to_nil
    @category.conditions.each { |c| c.update_attributes!(position: nil) } #need the ! to throw error if occur
  end

  def attempt_to_update_positions_per_user_entries
    params["conditions"].each do |condition_item_data|
      condition_item = Condition.find(condition_item_data["id"])
      condition_item_data["position"] = "blank" if condition_item_data["position"].blank?
      condition_item.update_attributes!(position: condition_item_data["position"])
    end
  end

  def make_or_update_condition
    @condition ? @condition.update!(condition_params) : @category.conditions.create!(condition_params)
  end
end
