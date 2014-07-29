class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :user_id
      t.string  :recipient_email
      t.string  :token

      t.timestamps
    end
  end
end
