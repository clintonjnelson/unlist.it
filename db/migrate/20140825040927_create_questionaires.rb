class CreateQuestionaires < ActiveRecord::Migration
  def change
    create_table :questionaires do |t|
      t.integer :user_id
      t.text    :intuitive
      t.text    :layout
      t.text    :purpose
      t.text    :making_unlistings
      t.text    :search_browse
      t.text    :notlike1
      t.text    :notlike2
      t.text    :keepit
      t.text    :junkit
      t.text    :breaks1
      t.text    :breaks2

      t.timestamps
    end
  end
end
