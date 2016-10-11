module V1::Polls
  class GetController < V1::ApplicationController
    layout 'v1/main'


    before_action :poll

    def detail
      @poll = DetailForMemberDecorator.new(@poll, @current_member) if member_signed_in?
      @poll = DetailForGuestDecorator.new(@poll) unless member_signed_in?

      set_meta(
        title: @poll.title,
        description: @poll.member.fullname,
        url: request.original_url,
        image: @poll.qrcode_image_url
      )
    end

    private

    def decode_poll_id(custom_key)
      Base64.urlsafe_decode64(custom_key).to_i - ENV['POLL_URL_ENCODER_KEY'].to_i
    end

    def poll
      @poll ||= ::Poll.find(decode_poll_id(params[:custom_key]))
    end
  end
end
