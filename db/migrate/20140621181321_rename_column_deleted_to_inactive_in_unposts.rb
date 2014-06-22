class RenameColumnDeletedToInactiveInUnposts < ActiveRecord::Migration
  def change
    rename_column :unposts, :deleted, :inactive
  end
end
