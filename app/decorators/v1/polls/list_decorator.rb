module V1::Polls
  class ListDecorator < V1::ApplicationDecorator
    delegate :title, :member, :get_photo, :photo_poll

    def poll
      object
    end

    def url
      poll_direct_access = ::Poll::DirectAccess.new(poll)

      "/v1/polls/#{poll_direct_access.encode_poll_id}"
    end
  end
end
