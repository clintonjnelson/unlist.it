class AddUseAvatarColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_avatar, :boolean
  end
end
