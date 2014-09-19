class ConditionsManager

  attr_reader :category, :condition_params, :conditions_params
  def initialize(category)
    @category = category
  end

  def add_or_update_condition(condition_params, conditions_params, obj_id=nil)
    @condition_params   = condition_params   #condition: { id: -, level: "--", position: -, ... }
    @conditions_params  = conditions_params  #conditions: { 'id': 1, 'position': ... } ##NOTE: no level, not changed here
    @existing_condition = Condition.where(id: obj_id).take
    response            = update_position_transaction
  end


  private
  def update_position_transaction
    begin
      ActiveRecord::Base.transaction do
        set_condition_positions_temporarily_to_nil
        set_main_condition
        attempt_to_update_other_positions_per_user_entries unless @conditions_params.blank?
      end
      @category.reload.reorder_conditions ##TODO: MOVE RELOAD TO THE MODEL
      return true
    rescue ActiveRecord::RecordInvalid
      return false
    end
  end

  def set_condition_positions_temporarily_to_nil
    @category.conditions.each { |c| c.update_attributes!(position: nil) } #need the ! to throw error if occur
  end

  def set_main_condition
    existing_condition? ? @existing_condition.update!(@condition_params) : @category.conditions.create!(@condition_params)
  end

  def existing_condition?
    @existing_condition.present?
  end

  def attempt_to_update_other_positions_per_user_entries
    @conditions_params.each do |condition_item_data|
      condition_item = Condition.find(condition_item_data["id"])
      condition_item_data["position"] = "blank" if condition_item_data["position"].blank?
      condition_item.update_attributes!(position:  condition_item_data["position"])
    end
  end
end
