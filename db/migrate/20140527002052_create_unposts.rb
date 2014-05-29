class CreateUnposts < ActiveRecord::Migration
  def change
    create_table :unposts do |t|
      t.integer   :user_id
      t.integer   :category_id
      t.integer   :condition_id
      t.string    :title
      t.text      :description
      t.string    :keyword1
      t.string    :keyword2
      t.string    :keyword3
      t.string    :keyword4
      t.string    :link
      t.integer   :price
      t.boolean   :travel
      t.integer   :distance
      t.integer   :zipcode
      t.timestamps
    end
  end
end
