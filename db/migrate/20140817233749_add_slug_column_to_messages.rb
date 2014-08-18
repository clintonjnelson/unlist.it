class AddSlugColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :slug, :string
  end
end
