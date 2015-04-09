class ImageUrl
  def initialize(url)
    @url = url
  end

  def url
    @url || ""
  end

  def from_image_url?
    url.class != ActionDispatch::Http::UploadedFile ? true : false
  end
  
  def split_url_for_cloudinary
    if from_image_url?
      url.split("/upload/").last
    end
  end
  
end