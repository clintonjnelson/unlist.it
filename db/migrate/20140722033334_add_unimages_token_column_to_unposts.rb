class AddUnimagesTokenColumnToUnposts < ActiveRecord::Migration
  def change
    add_column :unposts, :unimages_token, :string
  end
end
