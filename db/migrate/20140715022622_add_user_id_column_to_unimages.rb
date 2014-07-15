class AddUserIdColumnToUnimages < ActiveRecord::Migration
  def change
    add_column :unimages, :user_id, :integer
  end
end
