class RenameUnpostsTableToUnlistings < ActiveRecord::Migration
  def change
    rename_table :unposts, :unlistings
  end
end
