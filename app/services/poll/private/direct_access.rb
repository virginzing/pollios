module Poll::Private::DirectAccess

  private

  def encode_poll_id
    secret_key = ENV['POLL_URL_ENCODER_KEY'].to_i
    custom_key = (poll.id + secret_key).to_s

    @encode_poll_id ||= Base64.urlsafe_encode64(custom_key)
  end

  def open_app_link
    @open_app_link ||= 'pollios://poll?poll_id='
  end

  def host_app_url
    @host_app_url ||= Rails.env.production? ? 'http://pollios.com' : 'http://192.168.1.17:3000'
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

  def delete_qrcode_image
    File.delete(qrcode_raw_image_path)
    File.delete(qrcode_composed_image_path)
  end

  def generate_qrcode_image
    write_qrcode_raw_image(share_url)
    write_composed_qrcode
    url = upload_composed_qrcode_to_cloudinary['secure_url']
    delete_qrcode_image

    url
  end

  def qrcode_image_on_cloudinary_exist?
    uri = URI.parse(qrcode_image_url_on_cloudinary)

    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    response.code == Net::HTTPOK
  end

  def qrcode_image_url_on_cloudinary
    Cloudinary::Utils.cloudinary_url(encode_poll_id + '.png')
  end
end