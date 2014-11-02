class AddVisibilityColumnToUnlistings < ActiveRecord::Migration
  def change
    add_column :unlistings, :visibility, :string
  end
end
