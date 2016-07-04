module Member::Private::MemberActionGuard
require 'guard_message'

  private
  
  def can_add_friend?
    return [false, add_self_as_a_friend_message] if same_member
    return [false, already_friend_message(a_member)] if already_friend
    return [false, already_sent_request_message(a_member)] if already_sent_request
    return [false, already_blocked_message(a_member)] if already_block
    return [false, blocked_by_someone_message(a_member)] if blocked_by_someone(a_member)
    [true, nil]
  end

  def can_unfriend?
    return [false, unfriend_self_message] if same_member
    return [false, not_friend_message(a_member)] if not_friend
    [true, nil]
  end

  def can_follow?
    return [false, follow_self_message] if same_member
    return [false, already_followed_message] if already_follow
    return [false, not_official_account_message] if not_official_account
    return [false, already_blocked_message(a_member)] if already_block
    return [false, blocked_by_someone_message(a_member)] if blocked_by_someone(a_member)
    [true, nil]
  end

  def can_unfollow?
    return [false, unfollow_self_message] if same_member
    return [false, not_following_message] if not_following
    [true, nil]
  end

  def can_block?
    return [false, block_self_message] if same_member
    return [false, already_blocked_message(a_member)] if already_block
    [true, nil]
  end

  def can_unblock?
    return [false, unblock_self_message] if same_member
    return [false, not_blocking_message(a_member)] if not_blocking
    [true, nil]
  end

  def can_accept_friend_request?
    return [false, not_exist_incoming_request_message(a_member)] if not_exist_incoming_request
    return [false, friends_limit_exceed_message(a_member)] if friends_limit_exceed(member)
    return [false, friends_limit_exceed_message(a_member)] if friends_limit_exceed(a_member)
    return [false, already_blocked_message(a_member)] if already_block
    return [false, accept_incoming_block_message] if incoming_block
    [true, nil]
  end

  def can_deny_friend_request?
    return [false, not_exist_incoming_request_message(a_member)] if not_exist_incoming_request
    [true, nil]
  end

  def can_cancel_friend_request?
    return [false, not_exist_outgoing_request_message] if not_exist_outgoing_request
    [true, nil]
  end

  def can_report?
    return [false, report_self_message] if same_member
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

  def not_official_account
    a_member.member_type == 'citizen'
  end

  def already_block
    member_list.already_block_with?(a_member)
  end

  def not_blocking
    member_list.not_blocking_with?(a_member)
  end

  def blocked_by_someone(member)
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