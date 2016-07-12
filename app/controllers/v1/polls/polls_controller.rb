module V1::Polls
  class PollsController < ApplicationController
    layout 'v1/navbar_facebook_meta'

    def get
      poll_id = Base64.urlsafe_decode64(params[:custom_key]).to_i - ENV['POLL_URL_ENCODER_KEY'].to_i
      @poll = ::Poll.find_by(id: poll_id)

      qrcode_link_generator = GenerateQrcodeLink.new(@poll)

      @poll_link = qrcode_link_generator.link
      poll_id_encode = qrcode_link_generator.encode
      custom_url = qrcode_link_generator.url

      qr_temp_path = "app/assets/images/#{poll_id_encode}_temp.png"
      qr_final_path = "app/assets/images/#{poll_id_encode}_final.png"

      qr_img = RQRCode::QRCode.new(custom_url, size: 8).as_png
      IO.write(qr_temp_path, qr_img.to_s)

      qr_overlay = MiniMagick::Image.open('app/assets/images/qr_overlay.png')
      qr_overlay.resize('200x200')

      qr_for_compose = MiniMagick::Image.open(qr_temp_path)
      qr_for_compose.resize('200x200')
      result = qr_for_compose.composite(qr_overlay) do |c|
        c.compose 'Over'
      end
      File.delete(qr_temp_path)

      result.write(qr_final_path)
      @qr_code_url = Cloudinary::Uploader.upload(qr_final_path, public_id: poll_id_encode)
      File.delete(qr_final_path)

      @download_link = 'https://itunes.apple.com/us/app/pollios/id901397748?ls=1&mt=8'
    end
  end
end
