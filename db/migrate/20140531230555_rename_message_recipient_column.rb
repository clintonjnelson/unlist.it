class RenameMessageRecipientColumn < ActiveRecord::Migration
  def change
    rename_column :messages, :user_id, :recipient_id
  end
end
