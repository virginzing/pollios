module Member::MemberActionPrivate
  private
  def can_add_friend_with?(a_member)
    return false, "You can't add yourself as a friend." if member.id == a_member.id

    list = Member::MemberList.new(member)
    return false, "You and #{a_member.get_name} are already friends." if list.already_friend_with?(a_member)
    return false, "You already sent friend request to #{a_member.get_name}" if list.already_sent_request_to?(a_member)

    [true, '']
  end

  def process_friend_requests_transaction(a_member)
    Friend.transaction do
      process_outgoing_friend_request(a_member)
      process_incoming_friend_request(a_member)

      FlushCached::Member.new(member).clear_list_friends
      FlushCached::Member.new(a_member).clear_list_friends
    end
  end

  def accept_friendship(src_member, dst_member)
    @outgoing_relation.update!(status: :friend)
    @incoming_relation.update!(status: :friend)

    send_add_friend_request(src_member, dst_member, accept_friend: true, action: ACTION[:become_friend])
  end

  def process_outgoing_friend_request(a_member)
    if @new_outgoing
      puts '@LOG NEW_OUTGOING'
      send_add_friend_request(member, a_member)
    else
      puts '@LOG EXISTING_OUTGOING'
      if @outgoing_relation.invitee?
        accept_friendship(member, a_member)
      else
        @outgoing_relation.update!(status: :invite)
        send_add_friend_request(member, a_member)
      end
    end
  end

  def process_incoming_friend_request(a_member)
    return if @new_incoming
    puts '@LOG EXISTING_INCOMING'
    if @incoming_relation.invitee?
      accept_friendship(a_member, member)
    else
      unless @incoming_relation.friend?
        @incoming_relation.update!(status: :invitee)
      end
    end
  end

  def send_add_friend_request(src_member, dst_member, options = { action: ACTION[:request_friend] })
    AddFriendWorker.perform_async(src_member.id, dst_member.id, options) unless Rails.env.test?
  end

  def query_relationship_between(src_member, dst_member, status)
    new_record = false
    relation = Friend.where(follower: src_member, followed: dst_member).first_or_initialize do |member_relation|
      member_relation.follower = src_member
      member_relation.followed = dst_member
      member_relation.status = status
      member_relation.save!
      new_record = true
    end

    [new_record, relation]
  end
end