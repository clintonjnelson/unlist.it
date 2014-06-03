class AddOrderColumnToConditions < ActiveRecord::Migration
  def change
    add_column :conditions, :order, :integer
  end
end
