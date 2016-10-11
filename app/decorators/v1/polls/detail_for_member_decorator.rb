module V1::Polls
  class DetailForMemberDecorator < DetailForGuestDecorator
    def initialize(poll, current_member)
      @current_member ||= current_member
      @current_member_poll_inquiry ||= ::Member::PollInquiry.new(@current_member, poll)

      super(poll)
    end

    def poll
      object
    end

    def choices
      poll.choices.map { |choice| Choices::DetailDecorator.new(choice, total_vote, voting_info[:voted_choice_id]) }
    end

    def voted?
      @current_member_poll_inquiry.voted?
    end

    def voting_info
      @current_member_poll_inquiry.voting_info
    end

    def rating?
      poll.type_poll == 'rating'
    end

    def average_rating
      point = poll.choices.to_a.sum { |choice| choice.vote.to_f * choice.answer.to_f }
      avg = point.fdiv(total_vote).round(2)

      avg
    end

    def rating_width
      "#{(average_rating * 100) / 5}%"
    end

    def total_vote
      poll.choices.to_a.sum(&:vote)
    end
  end
end
