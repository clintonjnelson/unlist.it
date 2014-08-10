class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float   :latitude
      t.float   :longitude
      t.integer :radius

      t.timestamps
    end
  end
end
