module Member::Private::MemberAction
  include SymbolHash

  private

  def member_list
    @member_list ||= Member::MemberList.new(member)
  end

  def both_members
    [member, a_member]
  end

  def outgoing_relation
    @outgoing_relation ||= find_relationship_between(member, a_member)
  end

  def incoming_relation
    @incoming_relation ||= find_relationship_between(a_member, member)
  end

  def update_both_relations(relation_status_hash)
    outgoing_relation.update!(relation_status_hash)
    incoming_relation.update!(relation_status_hash)
  end

  def process_friend_requests_transaction
    @new_outgoing, @outgoing_relation = first_or_initialize_relationship_between(member, a_member, :invite)
    @new_incoming, @incoming_relation = first_or_initialize_relationship_between(a_member, member, :invitee)

    Friend.transaction do
      outgoing_friend_request
      incoming_friend_request
    end

    clear_friends_caches_for_members

    nil
  end

  def accept_friendship(src_member, dst_member)
    update_both_relations(status: :friend)
    send_friends_notification(src_member, dst_member, accept_friend: true, action: ACTION[:become_friend])
  end

  def outgoing_friend_request
    if @new_outgoing
      send_friends_notification(member, a_member)
    else
      if outgoing_relation.invitee?
        accept_friendship(member, a_member)
      else
        outgoing_relation.update!(status: :invite)
        send_friends_notification(member, a_member)
      end
    end
  end

  def incoming_friend_request
    return if @new_incoming

    if incoming_relation.invitee?
      accept_friendship(a_member, member)
    else
      unless incoming_relation.friend?
        incoming_relation.update!(status: :invitee)
      end
    end
  end

  def process_unfriend_request(options = { clear_cached: true })
    return unless outgoing_relation && incoming_relation

    update_both_relations(status: :nofriend)

    clear_friends_and_follwers_caches_for_members if options[:clear_cached]

    nil
  end

  def process_following
    if outgoing_relation.present?
      outgoing_relation.update(following: true)
    else
      Friend.create!(follower_id: member.id, followed_id: a_member.id, status: :nofriend, following: true)
    end

    clear_following_caches_for_members

    nil
  end

  def process_unfollow
    return unless outgoing_relation
    outgoing_relation.update(following: false)
    clear_following_caches_for_members

    nil
  end

  def process_block
    process_unfriend_request(clear_cached: false)
    process_unfollow

    outgoing_relation_block
    incoming_relation_block

    clear_friends_and_follwers_caches_for_members

    nil
  end

  def outgoing_relation_block
    if outgoing_relation.present?
      outgoing_relation.update(block: true)
    else
      Friend.create!(follower_id: member.id, followed_id: a_member.id, block: true)
    end
  end

  def incoming_relation_block
    if incoming_relation.present?
      incoming_relation.update(visible_poll: false)
    else
      Friend.create!(follower_id: a_member.id, followed_id: member.id, visible_poll: false)
    end
  end

  def process_unblock
    outgoing_relation.update(block: false)
    incoming_relation.update(visible_poll: true)

    clear_friends_and_follwers_caches_for_members

    nil
  end

  def process_accept_friend_request
    update_both_relations(active: true, status: :friend)
    send_friends_notification(member, a_member, action: ACTION[:become_friend])

    clear_friends_and_follwers_caches_for_members

    nil
  end

  def process_deny_friend_request
    update_both_relations(status: :nofriend)
    NotifyLog.check_update_cancel_request_friend_deleted(member, a_member)

    clear_friends_and_follwers_caches_for_members

    nil
  end

  def process_cancel_friend_request
    process_deny_friend_request
  end

  def process_report
    member.sent_reports.create!(reportee_id: a_member.id)

    a_member.with_lock do
      a_member.report_count += 1
      a_member.save!
    end

    nil
  end

  def send_friends_notification(src_member, dst_member, options = { action: ACTION[:request_friend] })
    V1::Member::FriendsRequestWorker.perform_async(src_member.id, dst_member.id, options)
  end

  def clear_friends_and_follwers_caches_for_members
    clear_friends_caches_for_members
    clear_followers_caches_for_members
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