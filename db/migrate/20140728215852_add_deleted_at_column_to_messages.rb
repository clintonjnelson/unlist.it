class AddDeletedAtColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :deleted_at, :datetime
  end
end
