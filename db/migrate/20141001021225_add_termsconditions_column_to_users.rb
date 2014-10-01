class AddTermsconditionsColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :termsconditions, :datetime
  end
end
