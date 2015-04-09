class ImageUrl
  def initialize(url)
    @url = url
  end
  
  def split_url_for_cloudinary
    @url.split("/upload/").last
  end
  
end