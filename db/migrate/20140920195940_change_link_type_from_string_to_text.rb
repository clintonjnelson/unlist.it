class ChangeLinkTypeFromStringToText < ActiveRecord::Migration
  def change
    change_table(:unlistings) do |t|
      t.change :link, :text
    end
  end
end
