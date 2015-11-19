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

  def can_add_friend?
    return false, "You can't add yourself as a friend." if same_member
    return false, "You and #{a_member.get_name} are already friends." if already_friend
    return false, "You already sent friend request to #{a_member.get_name}" if already_sent_request
    [true, '']
  end

  def can_unfriend?
    return false, "You are not friends with #{friend.get_name}." if not_friend
    [true, '']
  end

  def can_follow?
    return false, 'You already followed this account.' if already_follow
    [true, '']
  end

end