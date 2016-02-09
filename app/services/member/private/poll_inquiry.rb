module Member::Private::PollInquiry

  # private

  def can_view?
    return [false, ExceptionHandler::Message::Member::BAN] if poll.member.ban?
    return [false, ExceptionHandler::Message::Poll::UNDER_INSPECTION] if poll.black?
    return [false, ExceptionHandler::Message::Poll::DELETED] if poll.deleted_at.present?
    return [false, "You can't see draft poll."] if poll.draft
    return [false, ExceptionHandler::Message::Poll::OUTSIDE_GROUP] if member_outside_group_visibility?
    return [false, 'You are already not interested this poll.'] if not_interested?
    return [false, "You can't see this poll at this moment."] if incoming_block

    [true, nil]
  end

  def process_view
    Member::PollAction.new(member, poll).view
    poll
  end

  def can_vote?
    return [false, ExceptionHandler::Message::Poll::CLOSED] if poll.closed?
    return [false, ExceptionHandler::Message::Poll::EXPIRED] if poll.expire_date < Time.zone.now
    return [false, "This poll is allow vote for group's members."] if outside_group?
    return [false, 'This poll is allow vote for friends or following.'] if only_for_frineds_or_following?
    return [false, "This poll isn't allow your own vote."] if not_allow_your_own_vote?
    return [false, "You are already blocked #{poll.member.fullname}."] if outgoing_block

    [true, nil]
  end

  def member_outside_group_visibility?
    need_group_visibility_check? && poll_only_in_closed_group?
  end

  def outside_group?
    need_group_visibility_check? && !group_ids_visible_to_member?
  end

  def only_for_frineds_or_following?
    need_friends_following_visibility_check? && not_friends_or_following_with_creator
  end

  def not_allow_your_own_vote?
    owner_poll && !poll.creator_must_vote
  end

  def owner_poll
    poll.member_id == member.id
  end

  def need_group_visibility_check?
    !poll.public && poll.in_group
  end

  def need_friends_following_visibility_check?
    !owner_poll && !poll.public && !poll.in_group
  end

  def poll_only_in_closed_group?
    in_group_ids = poll.in_group_ids.split(',').map(&:to_i)

    in_group_ids.each do |group_id|
      return false if Group.cached_find(group_id).opened
      return false if Member::GroupList.new(member).active_ids.include?(group_id)
    end
  end

  def group_ids_visible_to_member?
    in_group_ids = poll.in_group_ids.split(',').map(&:to_i)
    member_active_group_ids = Member::GroupList.new(member).active_ids

    visible_group_ids = in_group_ids & member_active_group_ids
    !visible_group_ids.empty?
  end

  def member_listing
    Member::MemberList.new(member)
  end

  def not_friends_or_following_with_creator
    member_listing.not_friend_with?(poll.member) && member_listing.not_following_with?(poll.member)
  end

  def incoming_block
    member_listing.blocked_by_someone.include?(poll.member_id)
  end

  def outgoing_block
    member_listing.blocks_ids.include?(poll.member_id)
  end

  def voted_hash
    { voted: true, choice: voting_detail }
  end

  def voting_allows_hash
    { voted: false, can_vote: true }
  end

  def voting_not_allowed_with_reason_hash(message)
    { voted: false, can_vote: false, reason: message }
  end

  def voted_choice_id
    HistoryVote.member_voted_poll(member.id, poll.id)
  end

  def voting_detail
    voted_choice = Choice.cached_find(voted_choice_id.first.choice_id)
    { choice_id: voted_choice.id, answer: voted_choice.answer, vote: voted_choice.vote }
  end
  
end