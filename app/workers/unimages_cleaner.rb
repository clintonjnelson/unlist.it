class UnimagesCleaner
  include Sidekiq::Worker

  # HAVE YET TO BE ABLE TO TEST THIS WORKER FOR ALL BUT SET FILENAME TO NIL
  def perform(unimage_ids_array, exterminate=false)
    unimage_ids_array.each do |unimage_id|
      u = Unimage.find(unimage_id)
      u.remove_filename!           #tells CW to delete image
      u.remove_filename = true     #tells CW to make the attribute/column value = nil
      u.save                       #saves the column change to nil
      u.destroy if exterminate
    end
  end
end
