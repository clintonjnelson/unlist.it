class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :invites_ration
      t.integer :invites_max
      t.timestamps
    end
  end
end
