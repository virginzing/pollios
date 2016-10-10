module V1::Polls
  class GetController < V1::ApplicationController
    layout 'v1/main'

    before_action :set_poll
    before_action :set_poll_direct_access

    before_action do
      set_meta(
        title: @poll.title,
        description: @poll.member.fullname,
        url: request.original_url,
        image: @poll_direct_access.qrcode_image_url
      )
    end

    def detail
      @poll_open_app_url = @poll_direct_access.open_app_url
      @poll_qrcode_image_url = @poll_direct_access.qrcode_image_url
    end

    private

    def decode_poll_id(custom_key)
      Base64.urlsafe_decode64(custom_key).to_i - ENV['POLL_URL_ENCODER_KEY'].to_i
    end

    def set_poll_direct_access
      @poll_direct_access ||= ::Poll::DirectAccess.new(@poll)
    end

    def set_poll
      @poll ||= ::Poll.find_by(id: decode_poll_id(params[:custom_key]))
    end
  end
end