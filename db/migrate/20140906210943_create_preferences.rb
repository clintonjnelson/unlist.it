class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :user_id
      t.boolean :hit_notifications
      t.boolean :safeguest_contact
      t.timestamps
    end
  end
end
