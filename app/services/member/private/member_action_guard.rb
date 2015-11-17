module Member::Private::MemberActionGuard

  private

  def can_add_friend?
    case 
    when member.id == a_member.id
      return false, "You can't add yourself as a friend."
    when member_list.already_friend_with?(a_member)
      return false, "You and #{a_member.get_name} are already friends."
    when member_list.already_sent_request_to?(a_member)
      return false, "You already sent friend request to #{a_member.get_name}"
    else
      return true, ''
    end
  end

  def can_unfriend?
    case
    when member_list.not_friend_with?(a_member)
      return false, "You are not friends with #{friend.get_name}."
    else
      return true, ''
    end      
  end

end