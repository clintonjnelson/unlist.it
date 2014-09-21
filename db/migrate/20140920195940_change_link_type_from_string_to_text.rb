class ChangeLinkTypeFromStringToText < ActiveRecord::Migration
  def change
    change_table(:unlistings) do |t|
      t.change :link, :text #used to be string, but was too short for some urls
    end
  end
end
