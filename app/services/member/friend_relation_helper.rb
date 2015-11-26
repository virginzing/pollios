module Member::FriendRelationHelper
  # NOTE: private methods for interpreting/comprehensing Friend-Join status flags in relationship status
  # NOTE: not to be confuse with @member status query
  private def active?(a_member)
    a_member.member_active == true
  end

  private def friend_with?(a_member)
    a_member.member_status == 1
  end

  private def blocked?(a_member)
    a_member.member_block == true
  end

  private def active_friend_with?(a_member)
    active?(a_member) && friend_with?(a_member) && !blocked?(a_member)
  end

  private def requesting_friend_with?(a_member)
    a_member.member_status == 0 && active?(a_member)
  end

  private def following?(a_member)
    a_member.member_following == true && !friend_with?(a_member) && !a_member.citizen?
  end

  private def followed_by?(a_member)
    a_member.member_following == true && !friend_with?(a_member)
  end

  private def being_requested_friend_by?(a_member)
    a_member.member_status == 2 && active?(a_member)
  end

  private def blocked_friend?(a_member)
    active?(a_member) && blocked?(a_member) && friend_with?(a_member)
  end
end