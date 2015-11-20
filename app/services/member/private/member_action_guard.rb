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

  def can_add_friend?
    return false, "You can't add yourself as a friend." if same_member
    return false, "You and #{a_member.get_name} are already friends." if already_friend
    return false, "You already sent friend request to #{a_member.get_name}" if already_sent_request
    [true, '']
  end

  def can_unfriend?
    return false, "You are not friends with #{a_member.get_name}." if not_friend
    [true, '']
  end

  def can_follow?
    return false, 'You already followed this account.' if already_follow
    return false, 'This member is not official account.' if not_official_account
    [true, '']
  end

  def can_unfollow?
    return false, 'You are not following this account.' if not_following
    [true, '']
  end

  def can_block?
    return false, "You can't block yourself." if same_member
    return false, "You already blocked #{a_member.get_name}." if already_block
    [true, '']
  end

end