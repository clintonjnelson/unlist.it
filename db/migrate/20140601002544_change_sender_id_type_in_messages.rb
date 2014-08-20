class ChangeSenderIdTypeInMessages < ActiveRecord::Migration
  def change
    #change_column :messages, :sender_id, :integer
    # Change syntax for PostgreSQL to accept due to error:
      # PG::DatatypeMismatch: ERROR:  column "sender_id" cannot be cast automatically to type integer
      # HINT:  Specify a USING expression to perform the conversion.
    change_column :messages, :sender_id, 'integer USING CAST(sender_id AS integer)'
  end
end
