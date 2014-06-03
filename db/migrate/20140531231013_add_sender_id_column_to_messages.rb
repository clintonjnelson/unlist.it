class AddSenderIdColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sender_id, :string
  end
end
