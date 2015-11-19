module Member::Private::MemberAction
  include SymbolHash

  private

  def member_list
    @member_list ||= Member::MemberList.new(member)
  end

  def both_members
    [member, a_member]
  end

  def process_friend_requests_transaction
    @new_outgoing, @outgoing_relation = first_or_initialize_relationship_between(member, a_member, :invite)
    @new_incoming, @incoming_relation = first_or_initialize_relationship_between(a_member, member, :invitee)

    Friend.transaction do
      process_outgoing_friend_request
      process_incoming_friend_request
    end

    clear_friends_caches_for_members
  end

  def accept_friendship(src_member, dst_member)
    @outgoing_relation.update!(status: :friend)
    @incoming_relation.update!(status: :friend)

    send_friends_notification(src_member, dst_member, accept_friend: true, action: ACTION[:become_friend])
  end

  def process_outgoing_friend_request
    if @new_outgoing
      send_friends_notification(member, a_member)
    else
      if @outgoing_relation.invitee?
        accept_friendship(member, a_member)
      else
        @outgoing_relation.update!(status: :invite)
        send_friends_notification(member, a_member)
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
    @outgoing_friendship = find_relationship_between(member, a_member)
    @incoming_friendship = find_relationship_between(a_member, member)

    return unless outgoing_friendship && incoming_friendship

    process_outgoing_unfriend_relation
    process_incoming_unfriend_relation

    clear_friends_caches_for_members
    clear_followers_caches_for_members
  end

  def process_outgoing_unfriend_relation
    if !@outgoing_friendship.following
      @incoming_friendship.update!(status: :nofriend)
      @outgoing_friendship.destroy
    else
      @outgoing_friendship.update!(status: :nofriend)
    end
  end

  def process_incoming_unfriend_relation
    if !@incoming_friendship.following
      existing_friendship = Friend.where(follower: member, followed: a_member).first

      if existing_friendship.present?
        existing_friendship.update!(status: :nofriend)
      end

      @incoming_friendship.destroy
    else
      @incoming_friendship.update!(status: :nofriend)
    end
  end

  def process_following
    outgoing_following = find_relationship_between(member, a_member)

    if outgoing_following.present?
      outgoing_following.update(following: true)
    else
      Friend.create!(follower_id: member.id, followed_id: a_member.id, status: :nofriend, following: true)
    end

    clear_following_caches_for_members
  end

  def process_unfollow
    outgoing_following = find_relationship_between(member, a_member)
    outgoing_following.destroy

    clear_following_caches_for_members
  end

  def send_friends_notification(src_member, dst_member, options = { action: ACTION[:request_friend] })
    AddFriendWorker.perform_async(src_member.id, dst_member.id, options) unless Rails.env.test?
  end

  def clear_friends_caches_for_members
    both_members.each { |m| FlushCached::Member.new(m).clear_list_friends }
  end

  def clear_followers_caches_for_members
    both_members.each { |m| FlushCached::Member.new(m).clear_list_followers }
  end

  def clear_following_caches_for_members
    FlushCached::Member.new(member).clear_list_friends
    FlushCached::Member.new(a_member).clear_list_followers
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