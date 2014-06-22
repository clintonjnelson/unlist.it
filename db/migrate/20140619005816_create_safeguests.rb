class CreateSafeguests < ActiveRecord::Migration
  def change
    create_table :safeguests do |t|
      t.string  :email
      t.boolean :confirmed
      t.boolean :blacklisted

      t.timestamps
    end
  end
end
