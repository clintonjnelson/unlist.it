class Admin::ConditionsController < AdminController

  def new
    @condition = Condition.new
  end

  def create
    @category = Category.find(params[:condition][:category_id])
    if update_positions == true
      flash[:success] = "Condition was successfully saved."
      redirect_to admin_categories_path
    else
      flash[:error] = "Please fix the form/order errors below & try again."
      redirect_to new_admin_condition_path
    end
  end

  def conditions_by_category
    @conditions = Condition.where(category_id: params[:category_id]).all
    respond_to do |format|
      format.js {render 'conditions_by_category'}
    end
  end

  ###############Private Methods##############
  private
  def new_condition_params
    params.require(:condition).permit(:category_id, :level, :position)
  end

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
      attempt_to_update_positions_per_user_entries unless params["conditions"].blank?
    end
  end

  #this works
  def set_condition_positions_temporarily_to_nil
    @category.conditions.each { |c| c.update_attributes!(position: nil) } #need the ! to throw error if occur
  end

  def attempt_to_update_positions_per_user_entries
    params["conditions"].each do |condition_item_data|
      condition_item = Condition.find(condition_item_data["id"])
      condition_item_data["position"] = "blank" if condition_item_data["position"].blank?
      condition_item.update_attributes!(position: condition_item_data["position"])
    end
    @condition = @category.conditions.create!(new_condition_params)
  end
end
