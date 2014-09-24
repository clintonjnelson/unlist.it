class AddFoundColumnToUnlistings < ActiveRecord::Migration
  def change
    add_column :unlistings, :found, :boolean
  end
end
