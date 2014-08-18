class RenameUnpostIdColumnToUnlistingIdInUnimages < ActiveRecord::Migration
  def change
    rename_column :unimages, :unpost_id, :unlisting_id
  end
end
