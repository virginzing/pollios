# encoding: utf-8

class PollAttachmentUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave

  version :thumbnail do
    process :eager => true
    process :resize_to_fill => [200, 200]
    cloudinary_transformation :quality => 75
  end    

  version :original do
    process :eager => true
    cloudinary_transformation :quality => 75
  end    

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
