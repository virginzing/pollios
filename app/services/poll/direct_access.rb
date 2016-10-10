require 'net/http'

class Poll::DirectAccess
  include Poll::Private::DirectAccess

  attr_reader :poll

  def initialize(poll)
    @poll = poll
  end
  
  def open_app_url
    open_app_link + encode_poll_id
  end

  def share_url
    host_app_url + '/v1/polls/' + encode_poll_id
  end

  def qrcode_image_url
    return qrcode_image_url_on_cloudinary if qrcode_image_on_cloudinary_exist?

    generate_qrcode_image
  end

  def encode_poll_id
    secret_key = ENV['POLL_URL_ENCODER_KEY'].to_i
    custom_key = (poll.id + secret_key).to_s

    @encode_poll_id ||= Base64.urlsafe_encode64(custom_key)
  end
end
