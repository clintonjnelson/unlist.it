class CreateCategoriesConditions < ActiveRecord::Migration
  def change
    create_table :categories_conditions do |t|
      t.integer :category_id
      t.integer :condition_id
      t.timestamps
    end
  end
end
