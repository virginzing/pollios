module V1::Polls::Choices
  class DetailDecorator < V1::ApplicationDecorator
    attr_reader :total_vote
    delegate :id, :answer

    def initialize(choice, total_vote)
      @total_vote ||= total_vote

      super(choice)
    end

    def choice
      object
    end

    def vote
      vote = choice.vote.fdiv(total_vote)
      vote *= 100
      vote = vote.round(2)

      "#{vote}%"
    end


    def vote_url
      poll_direct_access = ::Poll::DirectAccess.new(choice.poll)

      "/v1/polls/#{poll_direct_access.encode_poll_id}/vote"
    end
  end
end
