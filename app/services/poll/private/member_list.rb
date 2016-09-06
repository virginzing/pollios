module Poll::Private::MemberList

  private

  def can_view?
    return [true, nil] unless viewing_member
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view

    [true, nil]
  end

  def can_mention?
    return [true, nil] unless viewing_member
    return [false, "You aren't vote this poll. Vote to see comments."] if not_voted_and_poll_not_closed_and_poll_creator_and_creator_must_vote

    [true, nil]
  end

  def all_voter
    voter = Member.joins('LEFT OUTER JOIN history_votes ON members.id = history_votes.member_id')
            .where("history_votes.poll_id = #{poll.id}")
            .where("history_votes.show_result = 't'")
            .order_by_name

    return voter unless choice
    voter.where("history_votes.choice_id = #{choice.id}")
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

  def all_watched
    Member.joins('LEFT OUTER JOIN watcheds ON members.id = watcheds.member_id')
      .where("watcheds.poll_id = #{poll.id}")
      .where('watcheds.comment_notify')
  end

  def vote_as_anonymous
    poll.vote_all - all_voter.count
  end

  def vote_choice_as_anonymous
    choice.vote - all_voter.count
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
    return all_mentionable unless outgoing_block_members.empty?

    all_mentionable - outgoing_block_members
  end

  def mentionable_member
    voter_visibility | commenter_visibility
  end

  def mentionable_member_and_creator
    mentionable_member | [poll.member]
  end

  def watched_visibility
    return all_watched unless viewing_member

    all_watched.viewing_by_member(viewing_member)
  end

  def poll_inquiry_service
    Member::PollInquiry.new(viewing_member, poll)
  end

  def outgoing_block_members
    return [] unless viewing_member

    Member::MemberList.new(viewing_member).blocks
  end

  def not_voted_and_poll_not_closed_and_poll_creator_and_creator_must_vote
    (!poll_inquiry_service.voted? && !poll.close_status) && (viewing_member == poll.member && poll.creator_must_vote)
  end

  def sort_by_name(list)
    list.sort_by { |m| m.fullname.downcase }
  end
end