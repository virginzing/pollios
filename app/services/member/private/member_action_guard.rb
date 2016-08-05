module Member::Private::MemberActionGuard
  private

  def can_add_friend?
    return [false, GuardMessage::Member.add_self_as_a_friend] if same_member
    return [false, GuardMessage::Member.already_friend(a_member)] if already_friend
    return [false, GuardMessage::Member.already_sent_request(a_member)] if already_sent_request
    return [false, GuardMessage::Member.official_account] if official_account?
    return [false, GuardMessage::Member.already_blocked(a_member)] if already_block
    return [false, GuardMessage::Member.blocked_by(a_member)] if blocked_by(a_member)
    [true, nil]
  end

  def can_unfriend?
    return [false, GuardMessage::Member.unfriend_self] if same_member
    return [false, GuardMessage::Member.not_friend(a_member)] if not_friend
    [true, nil]
  end

  def can_follow?
    return [false, GuardMessage::Member.follow_self] if same_member
    return [false, GuardMessage::Member.already_followed] if already_follow
    return [false, GuardMessage::Member.not_official_account] if not_official_account
    return [false, GuardMessage::Member.already_blocked(a_member)] if already_block
    return [false, GuardMessage::Member.blocked_by(a_member)] if blocked_by(a_member)
    [true, nil]
  end

  def can_unfollow?
    return [false, GuardMessage::Member.unfollow_self] if same_member
    return [false, GuardMessage::Member.not_following] if not_following
    [true, nil]
  end

  def can_block?
    return [false, GuardMessage::Member.block_self] if same_member
    return [false, GuardMessage::Member.already_blocked(a_member)] if already_block
    [true, nil]
  end

  def can_unblock?
    return [false, GuardMessage::Member.unblock_self] if same_member
    return [false, GuardMessage::Member.not_blocking(a_member)] if not_blocking
    [true, nil]
  end

  def can_accept_friend_request?
    return [false, GuardMessage::Member.not_exist_incoming_request(a_member)] if not_exist_incoming_request
    return [false, GuardMessage::Member.member_friends_limit_exceed(member)] if friends_limit_exceed(member)
    return [false, GuardMessage::Member.friends_limit_exceed(a_member)] if friends_limit_exceed(a_member)
    return [false, GuardMessage::Member.already_blocked(a_member)] if already_block
    # TODO : Remove this 
    return [false, GuardMessage::Member.accept_incoming_block] if incoming_block
    [true, nil]
  end

  def can_deny_friend_request?
    return [false, GuardMessage::Member.not_exist_incoming_request(a_member)] if not_exist_incoming_request
    [true, nil]
  end

  def can_cancel_friend_request?
    return [false, GuardMessage::Member.not_exist_outgoing_request] if not_exist_outgoing_request
    [true, nil]
  end

  def can_report?
    return [false, GuardMessage::Member.report_self] if same_member
    [true, nil]
  end

  def same_member
    member.id == a_member.id
  end

  def already_friend
    member_list.already_friend_with?(a_member)
  end

  def already_sent_request
    member_list.already_sent_request_to?(a_member)
  end

  def not_friend
    member_list.not_friend_with?(a_member)
  end

  def already_follow
    member_list.already_follow_with?(a_member)
  end

  def not_following
    member_list.not_following_with?(a_member)
  end

  def official_account?
    a_member.member_type != 'citizen'
  end

  def not_official_account
    !official_account?
  end

  def already_block
    member_list.already_block_with?(a_member)
  end

  def not_blocking
    member_list.not_blocking_with?(a_member)
  end

  def blocked_by(member)
    member_list.blocked_by_someone.include?(member.id)
  end

  def friends_limit_exceed(member)
    Member::MemberList.new(member).friends_limit_exceed?
  end

  def incoming_block
    Member::MemberList.new(a_member).already_block_with?(member)
  end

  def not_exist_incoming_request
    member_list.not_exist_incoming_request?(a_member)
  end

  def not_exist_outgoing_request
    member_list.not_exist_outgoing_request?(a_member)
  end

end