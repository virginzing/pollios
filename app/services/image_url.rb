class ImageUrl
  def initialize(url)
    @url = url
  end

  def url
    @url || ""
  end

  def check_from_upload_file?
    url.class == ActionDispatch::Http::UploadedFile ? true : false
  end
  
  def split_url_for_cloudinary
    unless check_from_upload_file?
      url.split("/upload/").last
    end
  end
  
end