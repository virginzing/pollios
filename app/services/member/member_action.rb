class Member::MemberAction
  include SymbolHash

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

    @outgoing_relation ||= query_relationship_between(member, a_member, :invite)
    @incoming_relation ||= query_relationship_between(a_member, member, :invitee)
    begin
      Friend.transaction do
        do_add_friend(a_member)
      end
    end
  end

  private def accept_friendship(src_member, dst_member)
    @outgoing_relation.update!(status: :friend)
    @incoming_relation.update!(status: :friend)

    send_add_friend_request(src_member, dst_member, accept_friend: true, action: ACTION[:become_friend])
  end

  private def do_add_friend(a_member)
    if @outgoing_relation.id.nil?
      send_add_friend_request(member, a_member)
    else
      if @outgoing_relation.invitee?
        accept_friendship(member, a_member)
      else
        @outgoing_relation.update!(status: :invite)
        send_add_friend_request(member, a_member)
      end
    end

    unless @incoming_relation.id.nil?
      if @incoming_relation.invitee?
        accept_friendship(a_member, member)
      else
        unless @incoming_relation.friend?
          @incoming_relation.update!(status: :invitee)
        end
      end
    end
    FlushCached::Member.new(member).clear_list_friends
    FlushCached::Member.new(a_member).clear_list_friends
  end

  private def send_add_friend_request(src_member, dst_member, options = { action: ACTION[:request_friend] })
    AddFriendWorker.perform_async(src_member.id, dst_member.id, options) unless Rails.env.test?
  end

  def query_relationship_between(src_member, dst_member, status)
    Friend.where(follower: src_member, followed: dst_member).first_or_initialize do |member_relation|
      member_relation.follower = src_member
      member_relation.followed = dst_member
      member_relation.status = status
      member_relation.save!
    end
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