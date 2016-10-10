module V1::Polls::Choices
  class DetailDecorator < V1::ApplicationDecorator
    delegate :id, :answer

    def choice
      object
    end

    def vote_url
      poll_direct_access = ::Poll::DirectAccess.new(choice.poll)

      "/v1/polls/#{poll_direct_access.encode_poll_id}/vote"
    end
  end
end
