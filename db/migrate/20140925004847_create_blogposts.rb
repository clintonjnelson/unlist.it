class CreateBlogposts < ActiveRecord::Migration
  def change
    create_table :blogposts do |t|
      t.text :title
      t.text :content
      t.text :link
      t.text :blogpic
      t.text :slug

      t.timestamps
    end
  end
end
