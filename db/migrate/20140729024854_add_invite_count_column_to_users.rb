class AddInviteCountColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invite_count, :integer
  end
end
