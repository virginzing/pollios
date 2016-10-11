module V1::Polls::Choices
  class DetailDecorator < V1::ApplicationDecorator
    attr_reader :total_vote, :voted_choice_id

    delegate :id, :answer

    def initialize(choice, total_vote, voted_choice_id)
      @total_vote ||= total_vote
      @voted_choice_id ||= voted_choice_id

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

    def voted?
      choice.id == voted_choice_id
    end

    def vote_url
      poll_direct_access = ::Poll::DirectAccess.new(choice.poll)

      "/v1/polls/#{poll_direct_access.encode_poll_id}/vote"
    end
  end
end
