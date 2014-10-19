class ChangeMessagesContentFromStringToText < ActiveRecord::Migration
  def change
    change_table(:messages) do |t|
      t.change :content, :text #used to be string, but dont want to limit messages too much
    end
  end
end
