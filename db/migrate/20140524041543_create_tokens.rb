class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string      :token
      t.integer     :user_id
      t.references  :tokenable, polymorphic: true
      t.timestamps
    end
  end
end
