module Poll::Private::DirectAccess

  private

  def open_app_link
    @open_app_link ||= 'pollios://poll?poll_id='
  end

  def host_app_url
    @host_app_url ||= Rails.env.production? ? 'http://pollios.com' : 'http://localhost:3000'
  end

  def qrcode_raw_image_path
    @qrcode_raw_image_path ||= "app/assets/images/#{encode_poll_id}_raw.png"
  end

  def qrcode_composed_image_path
    @qrcode_composed_image_path ||= "app/assets/images/#{encode_poll_id}_composed.png"
  end

  def write_qrcode_raw_image(share_link)
    qrcode_image = RQRCode::QRCode.new(share_link, size: 8).as_png
    IO.write(qrcode_raw_image_path, qrcode_image.to_s)
  end

  def write_composed_qrcode
    logo = MiniMagick::Image.open('app/assets/images/qr_overlay.png')
    logo.resize('200x200')

    qrcode_raw_image = MiniMagick::Image.open(qrcode_raw_image_path)
    qrcode_raw_image.resize('200x200')

    result = qrcode_raw_image.composite(logo) do |c|
      c.compose 'Over'
    end

    result.write(qrcode_composed_image_path)
  end

  def upload_composed_qrcode_to_cloudinary
    Cloudinary::Uploader.upload(qrcode_composed_image_path, public_id: encode_poll_id)
  end

  def qrcode_image_url_with_poll_image
    photo = @poll.get_photo.split('/')
    photo.insert(7, "w_588,o_78,l_#{encode_poll_id}.png")
    photo.join('/')
  end

  def delete_qrcode_image
    File.delete(qrcode_raw_image_path)
    File.delete(qrcode_composed_image_path)
  end

  def generate_qrcode_image
    write_qrcode_raw_image(share_url)
    write_composed_qrcode
    url = upload_composed_qrcode_to_cloudinary['secure_url']
    delete_qrcode_image

    return url if @poll.get_photo.blank?

    qrcode_image_url_with_poll_image
  end

  def qrcode_image_on_cloudinary_exist?
    return @has_image unless @has_image.nil?
    
    uri = URI.parse(qrcode_image_url_on_cloudinary)

    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    @has_image = response.code.to_i == 200

    @has_image
  end

  def qrcode_image_url_on_cloudinary
    return Cloudinary::Utils.cloudinary_url(encode_poll_id + '.png') if @poll.get_photo.blank?

    qrcode_image_url_with_poll_image
  end
end
