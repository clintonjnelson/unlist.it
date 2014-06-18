class AddPasswordResetColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prt,            :string
    add_column :users, :prt_created_at, :datetime
  end
end
