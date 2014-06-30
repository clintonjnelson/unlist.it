class CreateUnimages < ActiveRecord::Migration
  def change
    create_table :unimages do |t|
      t.integer :unpost_id
      t.string  :filename
      t.timestamps
    end
  end
end
