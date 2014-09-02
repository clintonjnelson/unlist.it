class AddLinkImageColumnToUnlistings < ActiveRecord::Migration
  def change
    add_column :unlistings, :link_image, :string
  end
end
