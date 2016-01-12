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

  def can_mention?
    return [true, nil] unless viewing_member
    return [false, "You aren't vote this poll. Vote to see comments."] if not_voted_and_poll_not_closed

    [true, nil]
  end

  def voter
    voter_visibility
  end

  def anonymous
    poll.vote_all - all_voter.count
  end

  def mentionable
    can_mention, message = can_mention?
    fail ExceptionHandler::UnprocessableEntity, message unless can_mention

    mentionable_visibility
  end

  # private

  def all_voter
    Member.joins('LEFT OUTER JOIN history_votes ON members.id = history_votes.member_id')
      .where("history_votes.poll_id = #{poll.id}")
      .where("history_votes.show_result = 't'")
      .order('LOWER(members.fullname)')
  end

  def all_commenter
    Member.joins('LEFT OUTER JOIN comments ON members.id = comments.member_id')
      .where("comments.poll_id = #{poll.id}")
      .uniq
  end

  def all_mentionable
    return sort_by_name(mentionable_member) if poll.creator_must_vote
    sort_by_name(mentionable_member_and_creator)
  end

  def voter_visibility
    return all_voter unless viewing_member
    all_voter.viewing_by_member(viewing_member)
  end

  def commenter_visibility
    return all_commenter unless viewing_member
    all_commenter.viewing_by_member(viewing_member)
  end

  def mentionable_visibility
    return all_mentionable if outgoing_block_members.count < 0
    all_mentionable - outgoing_block_members
  end

  def mentionable_member
    voter_visibility | commenter_visibility
  end

  def mentionable_member_and_creator
    mentionable_member | [poll.member]
  end

  def poll_inquiry_service
    Member::PollInquiry.new(viewing_member, poll)
  end

  def outgoing_block_members
    return [] unless viewing_member
    Member::MemberList.new(viewing_member).blocks
  end

  def not_voted_and_poll_not_closed
    !poll_inquiry_service.voted? && !poll.close_status
  end

  def sort_by_name(list)
    list.sort_by { |m| m.fullname.downcase }
  end
end