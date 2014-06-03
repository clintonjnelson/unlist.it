class Admin::ConditionsController < AdminController

  def new
    @condition = Condition.new
  end

  def create
    @category = Category.find(params[:condition][:category_id])
    @condition = @category.conditions.build(new_condition_params)
    if @condition.valid? && (reorder_conditions == true)
      flash[:success] = "Condition was successfully saved."
      redirect_to admin_categories_path
    else
      flash[:error] = "There were errors in the form. Please try again."
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
    params.require(:condition).permit(:category_id, :level, :order)
  end

  def reorder_conditions
    begin
      update_order_transaction
      #@category.conditions.renumber_order
      return true
    rescue ActiveRecord::RecordInvalid
      flash.now[:error] = "The ordering had errors. Please provide an acceptable order."
      return false
    end
  end

  def update_order_transaction
    ActiveRecord::Base.transaction do
      set_condition_orders_temporarily_to_nil
      attempt_to_update_orders_per_user_entries unless params["conditions"].blank?
    end
  end

  #this works
  def set_condition_orders_temporarily_to_nil
    @category.conditions.each { |c| c.update_attributes!(order: nil) } #need the ! to throw error if occur
  end

  def attempt_to_update_orders_per_user_entries
    params["conditions"].each do |condition_item_data|
      condition_item = Condition.find(condition_item_data["id"])
      condition_item_data["order"] = "blank" if condition_item_data["order"].blank?
      condition_item.update_attributes!(order: condition_item_data["order"])
    end
    @condition.order = new_condition_params[:order]
    @condition.save!
  end
end
