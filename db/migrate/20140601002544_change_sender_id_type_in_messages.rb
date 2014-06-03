class ChangeSenderIdTypeInMessages < ActiveRecord::Migration
  def change
    change_column :messages, :sender_id, :integer
  end
end
