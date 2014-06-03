class ChangeConditionsColumnNameOrderToPosition < ActiveRecord::Migration
  def change
    rename_column :conditions, :order, :position
  end
end
