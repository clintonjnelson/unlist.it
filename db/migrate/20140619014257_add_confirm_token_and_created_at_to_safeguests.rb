class AddConfirmTokenAndCreatedAtToSafeguests < ActiveRecord::Migration
  def change
    add_column :safeguests, :confirm_token,            :string
    add_column :safeguests, :confirm_token_created_at, :string
  end
end
