class AddDeletedColumnToUnposts < ActiveRecord::Migration
  def change
    add_column :unposts, :deleted, :boolean
  end
end
