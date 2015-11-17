class Member::MemberAction
  include Member::Private::MemberAction

  attr_reader :member

  def initialize(member, options = {})
    @member = member
    @options = options
  end

  def add_friend(a_member)
    can_add_friend, message = can_add_friend_with?(a_member)
    fail message unless can_add_friend

    @new_outgoing, @outgoing_relation = query_relationship_between(member, a_member, :invite)
    @new_incoming, @incoming_relation = query_relationship_between(a_member, member, :invitee)

    process_friend_requests_transaction(a_member)
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