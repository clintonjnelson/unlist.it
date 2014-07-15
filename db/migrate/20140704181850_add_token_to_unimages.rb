class AddTokenToUnimages < ActiveRecord::Migration
  def change
    add_column :unimages, :token, :string
  end
end
