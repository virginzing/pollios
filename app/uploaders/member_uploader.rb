# encoding: utf-8

class MemberUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave
  # storage :fog
  # storage :file
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:

  version :thumbnail do
    process :eager => true
    process :resize_to_fill => [180, 180]
  end

  version :cover do
    process :eager => true
    process :resize_to_fit => [640]
  end

  version :thumbnail_small do
    process :eager => true
    process :resize_to_fill => [30, 30]
  end    

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  
    "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

end
