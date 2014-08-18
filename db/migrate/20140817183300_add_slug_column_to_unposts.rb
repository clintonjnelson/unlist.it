class AddSlugColumnToUnposts < ActiveRecord::Migration
  def change
    add_column :unposts, :slug, :string
  end
end
