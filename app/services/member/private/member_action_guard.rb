module Member::Private::MemberActionGuard

  private

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

  def incoming_friends_over_limit
    member_list.friends_over_limit?
  end

  def outgoing_friends_over_limit
    Member::MemberList.new(a_member).friends_over_limit?
  end

  def incoming_block
    Member::MemberList.new(a_member).already_block_with?(member)
  end

  def not_exist_request
    member_list.not_exist_request?(a_member)
  end

  def can_add_friend?
    return false, "You can't add yourself as a friend." if same_member
    return false, "You and #{a_member.get_name} are already friends." if already_friend
    return false, "You already sent friend request to #{a_member.get_name}." if already_sent_request
    return false, "You are currently blocking #{a_member.get_name}." if already_block
    [true, '']
  end

  def can_unfriend?
    return false, "You can't unfriend yourself." if same_member
    return false, "You are not friends with #{a_member.get_name}." if not_friend
    [true, '']
  end

  def can_follow?
    return false, "You can't follow yourself." if same_member
    return false, 'You already followed this account.' if already_follow
    return false, 'This member is not official account.' if not_official_account
    return false, "You are currently blocking #{a_member.get_name}." if already_block
    [true, '']
  end

  def can_unfollow?
    return false, "You can't unfollow yourself." if same_member
    return false, 'You are not following this account.' if not_following
    [true, '']
  end

  def can_block?
    return false, "You can't block yourself." if same_member
    return false, "You already blocked #{a_member.get_name}." if already_block
    [true, '']
  end

  def can_unblock?
    return false, "You can't unblock yourself." if same_member
    return false, "You are not blocking #{a_member.get_name}." if not_blocking
    [true, '']
  end

  def can_accept_friend_request?
    return false, 'This request is not existing.' if not_exist_request
    return false, "Your friends has over #{member.friend_limit} people." if incoming_friends_over_limit
    return false, "#{a_member.get_name} friends has over #{member.friend_limit} people." if outgoing_friends_over_limit
    return false, "You are currently blocking #{a_member.get_name}." if already_block
    return false, "You can't accept request at this moment." if incoming_block
    [true, '']
  end

  def can_deny_friend_request?
    return false, 'This request is not existing.' if not_exist_request
    [true, '']
  end

end