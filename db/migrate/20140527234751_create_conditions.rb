class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.string :level
      t.integer :category_id

      t.timestamps
    end
  end
end
