module V1::Polls
  class DetailForGuestDecorator < V1::ApplicationDecorator
    attr_reader :poll_direct_access

    delegate :title, :member, :get_photo, :choices

    def initialize(poll)
      @poll_direct_access ||= ::Poll::DirectAccess.new(poll)

      super(poll)
    end

    def url
      "/v1/polls/#{poll_direct_access.encode_poll_id}"
    end

    def open_app_url
      poll_direct_access.open_app_url
    end

    def qrcode_image_url
      poll_direct_access.qrcode_image_url
    end
  end
end
