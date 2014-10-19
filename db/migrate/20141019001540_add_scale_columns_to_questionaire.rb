class AddScaleColumnsToQuestionaire < ActiveRecord::Migration
  def change
    add_column :questionaires, :intuitive_scale,         :integer
    add_column :questionaires, :purpose_scale,           :integer
    add_column :questionaires, :notlike1_scale,          :integer
    add_column :questionaires, :notlike2_scale,          :integer
    add_column :questionaires, :keepit_scale,            :integer
    add_column :questionaires, :layout_scale,            :integer
    add_column :questionaires, :making_unlistings_scale, :integer
    add_column :questionaires, :search_browse_scale,     :integer
    add_column :questionaires, :junkit_scale,            :integer
  end
end
