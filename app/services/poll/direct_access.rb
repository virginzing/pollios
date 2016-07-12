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
end