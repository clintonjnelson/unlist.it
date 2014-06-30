# encoding: utf-8
class UnimageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick


  ############################## STORAGE LOCATION ##############################
  def fog_directory
    'unlist-unimages'  #S3 bucket
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}" #eg: "uploads/avatar_uploader/user/1"
  end

  def cache_dir
    '/tmp/avitar-cache'
  end

  ############################## PREP FOR STORAGE ##############################
  process convert: 'jpg'  #all files saved as jpg

  def extension_white_list
    %w(gif jpg jpeg png tif)  #allowed avatar filetypes
  end

  def default_url         #when no file is uploaded
    'default_avatar.jpg'  #default: 'app/assets/images/default_avatar.jpg'
  end

  def filename
     "#{secure_token}.jpg" if original_filename.present?
  end


  ############################### MANIPULATE FILE ##############################
  # Create different versions of your uploaded files:
  version :full_unimage do
    process resize_to_fit: [500, 500]
  end
  version :thumb_unimage do
    process resize_to_fit: [120, 120]
  end


  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
