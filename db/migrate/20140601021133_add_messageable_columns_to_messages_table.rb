class AddMessageableColumnsToMessagesTable < ActiveRecord::Migration
  def change
    add_column :messages, :messageable_type, :string
    add_column :messages, :messageable_id,   :integer
  end
end
