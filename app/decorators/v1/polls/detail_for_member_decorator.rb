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
      total_vote = poll.choices.sum(&:vote)

      poll.choices.map { |choice| Choices::DetailDecorator.new(choice, total_vote, voting_info[:voted_choice_id]) }
    end

    def voted?
      @current_member_poll_inquiry.voted?
    end

    def voting_info
      @current_member_poll_inquiry.voting_info
    end

    def rating?
      poll.poll_type == 2
    end

    def average_rating

    end
  end
end
