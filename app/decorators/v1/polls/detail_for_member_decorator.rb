module V1::Polls
  class DetailForMemberDecorator < V1::ApplicationDecorator
    attr_reader :current_member, :current_member_poll_inquiry

    delegate :title, :member, :get_photo

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

      poll.choices.map { |choice| Choices::DetailDecorator.new(choice, total_vote) }
    end

    def vote?
      @current_member_poll_inquiry.voted?
    end
  end
end
