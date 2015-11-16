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

    # do_add_friend(a_member)
    # do_accept_friend_from(a_member)
  end

  private def do_add_friend(a_member)
    need_to_invite = !invitation_already_exists?(a_member)
    need_to_invite
  end

  private def invitation_already_exists?(a_member)
    invitation_exists = true
    Friend.where(follower: member, followed: a_member).first_or_initialize do |member_relation|
      member_relation.follower = member
      member_relation.followed = a_member
      member_relation.status = :invite
      member_relation.save!
      invitation_exists = false
    end
    invitation_exists
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