class Poll::MemberList

  attr_reader :poll, :viewing_member

  def initialize(poll, options = {})
    @poll = poll

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]

    can_view, message = can_view?
    fail ExceptionHandler::UnprocessableEntity, message unless can_view
  end

  def can_view?
    return [true, nil] unless viewing_member
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view

    [true, nil]
  end

  def voter
    voter_visibility
  end

  def anonymous
    poll.vote_all - all_voter.count
  end

  def mentionable
    all_mentionale
  end

  private

  def all_voter
    Member.joins('LEFT OUTER JOIN history_votes ON members.id = history_votes.member_id')
      .where("history_votes.poll_id = #{poll.id}")
      .where("history_votes.show_result = 't'")
      .order('LOWER(members.fullname)')
  end

  def voter_visibility
    return all_voter unless viewing_member
    all_voter.viewing_by_member(viewing_member)
  end

  def poll_inquiry_service
    Member::PollInquiry.new(viewing_member, poll)
  end
end