module Member::Private::MemberAction
  include SymbolHash

  private

  def member_list
    @member_list ||= Member::MemberList.new(member)
  end

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

  def process_friend_requests_transaction
    Friend.transaction do
      process_outgoing_friend_request
      process_incoming_friend_request

      clear_friends_caches_for_members
    end
  end

  def accept_friendship(src_member, dst_member)
    @outgoing_relation.update!(status: :friend)
    @incoming_relation.update!(status: :friend)

    send_add_friend_request(src_member, dst_member, accept_friend: true, action: ACTION[:become_friend])
  end

  def process_outgoing_friend_request
    if @new_outgoing
      send_add_friend_request(member, a_member)
    else
      if @outgoing_relation.invitee?
        accept_friendship(member, a_member)
      else
        @outgoing_relation.update!(status: :invite)
        send_add_friend_request(member, a_member)
      end
    end
  end

  def process_incoming_friend_request
    return if @new_incoming

    if @incoming_relation.invitee?
      accept_friendship(a_member, member)
    else
      unless @incoming_relation.friend?
        @incoming_relation.update!(status: :invitee)
      end
    end
  end

  def process_unfriend_request_with
    outgoing_friendship = find_relationship_between(member, a_member)
    incoming_friendship = find_relationship_between(a_member, member)

    return unless outgoing_friendship && incoming_friendship

    process_outgoing_unfriend_relation
    process_incoming_unfriend_relation

    clear_friends_caches_for_members
    clear_followers_caches_for_members
  end

  # TODO: Finish this.
  def process_outgoing_unfriend_relation
  end

  # TODO: Finish this.
  def process_incoming_unfriend_relation
  end

  def send_add_friend_request(src_member, dst_member, options = { action: ACTION[:request_friend] })
    AddFriendWorker.perform_async(src_member.id, dst_member.id, options) unless Rails.env.test?
  end

  def clear_friends_caches_for_members
    [member, a_member].each { |m| FlushCached::Member.new(m).clear_list_friends }
  end

  def clear_followers_caches_for_members
    [member, a_member].each { |m| FlushCached::Member.new(m).clear_list_followers }
  end

  def find_relationship_between(src_member, dst_member)
    Friend.find_by(follower_id: src_member.id, followed_id: dst_member.id)
  end

  def first_or_initialize_relationship_between(src_member, dst_member, status)
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