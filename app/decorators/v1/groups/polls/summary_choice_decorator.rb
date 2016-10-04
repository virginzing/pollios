module V1::Groups::Polls
  class SummaryChoiceDecorator < V1::ApplicationDecorator
    attr_reader :total_vote

    delegate :answer

    def initialize(choice, total_vote)
      @total_vote ||= total_vote

      super(choice)
    end

    def choice
      object
    end

    def vote
      vote = choice.vote.fdiv(total_vote)
      vote = vote * 100
      vote = vote.round(2)

      "#{vote}%"
    end
  end
end
