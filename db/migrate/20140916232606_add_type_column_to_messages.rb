class AddTypeColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :msg_type, :string
  end
end
