module V1::Groups::Polls
  class SummaryListDecorator < V1::ApplicationDecorator
    delegate :title, :member, :get_photo, :vote_all, :close_status

    def poll
      object
    end

    def choices
      total_vote = poll.choices.inject(0) { |sum, choice| sum += choice.vote }

      poll.choices.sort_by(&:vote).reverse!.map do |choice|
        ::V1::Groups::Polls::SummaryChoiceDecorator.new(choice, total_vote)
      end
    end
  end
end
