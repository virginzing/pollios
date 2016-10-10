module Member::Private::PollInquiry

  def can_view?
    return [false, ExceptionHandler::Message::Member::BAN] if poll.member.ban?
    return [false, ExceptionHandler::Message::Poll::UNDER_INSPECTION] if poll.black?
    return [false, ExceptionHandler::Message::Poll::DELETED] if poll.deleted_at.present?
    return [false, GuardMessage::Poll.draft_poll] if poll.draft
    return [false, ExceptionHandler::Message::Poll::OUTSIDE_GROUP] if member_outside_group_visibility?
    return [false, GuardMessage::Poll.already_not_interest] if not_interested?
    return [false, GuardMessage::Poll.poll_incoming_block] if incoming_block

    [true, nil]
  end

  def pending_groups
    {
      type: :group,
      group: poll.groups.map do |group|
        { group_id: group.id, name: group.name }
      end
    }
  end

  def pending_friends
    {
      type: :member,
      member: [poll.member].map do |member|
        { member_id: member.id, name: member.fullname }
      end
    }
  end

  def can_vote?
    can_view, message = can_view?
    return [false, message] unless can_view

    return [false, ExceptionHandler::Message::Poll::CLOSED] if poll.closed?
    return [false, ExceptionHandler::Message::Poll::EXPIRED] if expired_poll?
    # return [false, GuardMessage::Poll.allow_vote_for_group_member] if outside_group?
    # return [false, GuardMessage::Poll.only_for_frineds_or_following] if only_for_frineds_or_following?
    return [false, GuardMessage::Poll.not_allow_your_own_vote] if not_allow_your_own_vote?
    return [false, GuardMessage::Poll.you_are_already_block] if outgoing_block

    return [pending_groups, GuardMessage::Poll.pending_vote(:groups, poll.groups)] if outside_group?
    return [pending_friends, GuardMessage::Poll.pending_vote(:friends, [poll.member])] if only_for_frineds_or_following?
    [true, nil]
  end

  def can_comment?
    can_view, message = can_view?
    return [false, message] unless can_view

    return [false, GuardMessage::Poll.have_to_vote_before('comment')] if not_closed_and_must_vote?
    return [false, GuardMessage::Poll.not_allow_comment] if not_allow_comment?

    [true, nil]
  end

  # private

  def process_view
    Member::PollAction.new(member, poll).view
    poll
  end

  def member_outside_group_visibility?
    need_group_visibility_check? && poll_only_in_closed_group?
  end

  def expired_poll?
    return false unless poll.expire_date

    poll.expire_date < Time.zone.now
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
    @member_listing ||= Member::MemberList.new(member)
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

  def not_closed_and_must_vote?
    not_closed? && must_vote?
  end

  def not_closed?
    !poll.close_status
  end

  def must_vote?
    allow_your_own_vote? && not_voted?
  end

  def allow_your_own_vote?
    !not_allow_your_own_vote?
  end

  def not_voted?
    !Member::PollInquiry.new(member, poll).voted?
  end

  def not_allow_comment?
    !poll.allow_comment
  end

  def poll_in_public?
    poll.public
  end

  def poll_in_groups?
    poll.in_group
  end

  def poll_in_public_hash
    { in: 'Public' }
  end

  def poll_in_groups_hash
    { 
      in: 'Group',
      group_detail: poll_in_groups_details
    }
  end

  def poll_in_friend_following 
    { in: 'Friends & Following' }
  end

  def poll_in_groups_details
    groups_available = Member::GroupList.new(member).groups_available_for_poll(poll)

    groups_as_json = []
    groups_available.each do |group|
      groups_as_json << GroupDetailSerializer.new(group).as_json
    end

    groups_as_json
  end

  def voted_hash
    { voted: true, voted_choice_id: voted_choice_for_member[:choice_id] }.merge(voting_detail)
  end

  def voting_allows_hash
    { voted: false, can_vote: true }
  end

  def voting_not_allowed_with_reason_hash(message)
    { voted: false, can_vote: false, reason: message }
  end

  def voted_choice_for_member
    voted_all.find { |vote_info| vote_info[:poll_id] == poll.id }
  end

  def voting_detail
    return {} if poll.vote_all == 0
    if poll.type_poll == 'freeform'
      freeform_voting_detail
    else
      rating_voting_detail
    end
  end

  def freeform_voting_detail
    voted_choice = Choice.cached_find(member_voted_choice[:choice_id])
    show_choice = poll.get_vote_max | [{ choice_id: voted_choice.id, answer: voted_choice.answer, vote: voted_choice.vote }]
    show_choice -= [poll.get_vote_max[1]] if show_choice.count == 3
    { choices: show_choice }
  end

  def rating_voting_detail
    score = 0.0
    poll.choices.each { |choice| score += (choice.answer.to_i * choice.vote) }
    rating = (score / poll.vote_all).round(1)
    { rating: rating }
  end

  def voting_detail_creator_must_not_vote
    return {} if poll.vote_all == 0
    if poll.type_poll == 'freeform'
      { choices: poll.get_vote_max }
    else
      rating_voting_detail
    end
  end

end