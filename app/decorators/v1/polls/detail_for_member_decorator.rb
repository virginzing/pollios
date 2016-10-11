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
      # rubocop:disable Style/SingleLineBlockParams
      # rubocop:disable Lint/UselessAssignment
      total_vote = poll.choices.inject(0) { |sum, choice| sum += choice.vote }

      poll.choices.map { |choice| Choices::DetailDecorator.new(choice, total_vote, voting_info[:voted_choice_id]) }
    end

    def voted?
      @current_member_poll_inquiry.voted?
    end

    def voting_info
      @current_member_poll_inquiry.voting_info
    end
  end
end
