class Member::MemberAction

  attr_reader :member

  def initialize(member, options = {})
    @member = member
    @options = options
  end

  private def can_add_friend_with?(a_member)
    return false, "You can't add yourself as a friend." if member.id == a_member.id

    list = Member::MemberList.new(member)
    return false, "You and #{a_member.get_name} are already friends." if list.already_friend_with?(a_member)
    return false, "You already sent friend request to #{a_member.get_name}" if list.already_sent_request_to?(a_member)

    [true, '']
  end

  def add_friend(a_member)
    can_add_friend, message = can_add_friend_with?(a_member)
    fail message unless can_add_friend

    do_add_friend(a_member)
    # do_accept_friend_from(a_member)
  end

  private def do_add_friend(a_member)
    need_to_invite, member_relation = query_relationship_between(member, a_member)
    if need_to_invite
      send_friend_request_to(a_member, action: ACTION[:request_friend])
    else
      if member_relation.invitee?
      else
      end
    end
  end

  private def send_add_friend_request_to(a_member, options = {})
    AddFriendWorker.perform_async(member.id, a_member.id, options) unless Rails.env.test?
  end

  private def query_relationship_between(src_member, dst_member)
    is_new_relationship = false
    relation = Friend.where(follower: src_member, followed: dst_member).first_or_initialize do |member_relation|
      member_relation.follower = src_member
      member_relation.followed = dst_member
      member_relation.status = :invite
      # member_relation.save!
      is_new_relationship = true
    end
    [is_new_relationship, relation]
  end

  def unfriend(a_member)
  end

  def add_close_friend(a_member)
  end

  def remove_close_friend(a_member)
  end

  def follow(a_member)
  end

  def unfollow(a_member)
  end

  def accept_friend(a_member)
  end

  def deny_friend(a_member)
  end

  def block(a_member)
  end

  def unblock(a_member)
  end

end