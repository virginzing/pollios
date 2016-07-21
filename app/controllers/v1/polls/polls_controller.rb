module V1::Polls
  class PollsController < V1::ApplicationController
    layout 'v1/navbar_facebook_meta'

    def get
      @poll = ::Poll.find_by(id: decode_poll_id(params[:custom_key]))

      poll_direct_access = Poll::DirectAccess.new(@poll)
      @poll_open_app_url = poll_direct_access.open_app_url
      @poll_qrcode_image_url = poll_direct_access.qrcode_image_url
    end

    private

    def decode_poll_id(custom_key)
      Base64.urlsafe_decode64(custom_key).to_i - ENV['POLL_URL_ENCODER_KEY'].to_i
    end
  end
end
