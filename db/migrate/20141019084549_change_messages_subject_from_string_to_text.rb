class ChangeMessagesSubjectFromStringToText < ActiveRecord::Migration
  def change
    change_table(:messages) do |t|
      t.change :subject, :text #used to be string, but want to avoid error potential
    end
  end
end
