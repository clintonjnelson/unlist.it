# encoding: utf-8
class BlogpicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  ############################## STORAGE LOCATION ##############################
  def fog_directory
    'unlist-blogpics'  #S3 bucket
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}" #eg: "uploads/blogpic_uploader/user/1"
  end

  def cache_dir
    '/tmp/blogpic-cache'
  end

  ############################## PREP FOR STORAGE ##############################
  process convert: 'jpg'  #all files saved as jpg

  def extension_white_list
    %w(gif jpg jpeg png tif)  #allowed blogpic filetypes
  end

  def default_url         #when no file is uploaded
    'default_blogpic.jpg'  #default: 'app/assets/images/default_blogpic.jpg'
  end

  def filename
     "#{secure_token}.jpg" if original_filename.present?
  end


  ############################### MANIPULATE FILE ##############################
  # Create different versions of your uploaded files:
  version :full_blogpic do
    process resize_to_fit: [500, 500]
  end
  version :thumb_blogpic do
    process resize_to_fit: [80, 80]
  end


  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end
end
