module Member::Private::GroupAction

  private

  def member_listing_service
    @member_listing_service ||= Group::MemberList.new(group)
  end

  def relationship_to_group(member)
    group.group_members.find_by(member_id: member.id)
  end

  def process_create_group
    @group = build_new_group
    initialize_new_group
    group
  end

  def build_new_group
    group = Group.new new_group_params_hash
    group.save!
    group
  end

  def new_group_params_hash
    {
      member_id: member.id,
      name: group_params[:name],
      description: group_params[:description],
      cover: group_params[:cover],
      cover_preset: group_params[:cover_preset]
    }    
  end

  def initialize_new_group
    set_group_cover
    set_creator_as_admin
    create_group_company
    process_invite_friends(group_params[:friend_ids]) if group_params[:friend_ids].present?

    clear_group_cache_for_member(member)
  end

  def set_group_cover
    cover = group_params[:cover]
    cover_group_url = ImageUrl.new(cover)
    return unless cover && cover_group_url.from_image_url?

    group.update_column(:cover_preset, '0')
    group.update_column(:cover, cover_group_url.split_cloudinary_url)
  end

  def set_creator_as_admin
    group.group_members.create(member_id: member.id, is_master: true, active: true)
  end

  def create_group_company
    return unless member.company.present?
    group.create_group_company(company: member.get_company)
  end

  def process_invite_friends(friend_ids)
    member_ids_to_invite = member_listing_service.filter_non_members_from_list(friend_ids)
    
    member_ids_to_invite.each do |id_to_invite|
      invite_friend_id(id_to_invite)
    end

    clear_member_cache_for_group
    send_invite_friends_to_group_notification(member_ids_to_invite)

    friends_can_not_invite(friend_ids, member_ids_to_invite)
  end

  def invite_friend_id(friend_id)
    group.group_members.create(member_id: friend_id, is_master: false, active: false, invite_id: member.id)
    clear_group_cache_for_member(Member.cached_find(friend_id))
  end

  def friends_can_not_invite(friend_ids, invite_ids)
    can_not_invite_ids = friend_ids - invite_ids
    return if can_not_invite_ids.count == 0
    members_can_not_invite = Member.find(can_not_invite_ids).map(&:fullname).join(', ')
    message = "You can't invite #{members_can_not_invite} to #{group.name}."

    message
  end

  def precess_poke_invited_friends
    send_poke_invited_friends_to_group_notification(a_member.id)

    nil
  end

  def process_cancel_invite_friends
    process_cancel_request(a_member)
  end

  def process_leave(member)
    remove_role_group_admin(member)
    relationship_to_group(member).destroy

    clear_group_member_relation_cache(member)

    group
  end

  def process_join_request
    being_invited_by_admin_or_trigger? ? join_group(member) : ask_join_request
  end

  def process_cancel_request(member)
    group.request_groups.find_by(member_id: member.id).destroy if being_sent_join_request?(member)
    process_reject_request(member) if being_invited?(member)

    clear_group_member_relation_cache(member)
    clear_group_member_requesting_cache

    group
  end

  def process_accept_request
    being_invited_by_admin_or_trigger? ? join_group(member) : process_join_request
    group
  end

  def being_sent_join_request?(member)
    group.request_groups.find_by(member_id: member.id).present?
  end

  def being_invited?(member)
    return false unless relationship_to_group(member).present?
    !relationship_to_group(member).active
  end

  def being_invited_by_admin_or_trigger?
    return false unless being_invited?(member)
    return true if member_listing_service.admin?(Member.cached_find(relationship_to_group(member).invite_id))
    member.id == relationship_to_group(member).invite_id
  end

  def ask_join_request
    group.need_approve ? sent_join_request : join_group(member)
  end

  def sent_join_request
    group.request_groups.create(member_id: member.id)

    clear_group_member_relation_cache(member)
    clear_group_member_requesting_cache

    send_join_group_request_notification

    { group: group, status: :requesting }
  end

  def join_group(member)
    group.group_members.create(member_id: member.id, is_master: false) unless relationship_to_group(member).present?
    relationship_to_group(member).update!(active: true)

    add_member_to_company(member)
    set_member_following_company(member)

    clear_group_member_relation_cache(member)

    send_join_group_notification(member)

    { group: group, status: :member }
  end

  def add_member_to_company(member)
    return unless group.company? && !group.system_group
    CompanyMember.add_member_to_company(member, group.get_company)
  end

  def set_member_following_company(member)
    return unless group.member.company?
    Company::FollowOwnerGroup.new(member, group.member_id).follow!
  end

  def process_reject_request(member)
    delete_group_being_invited_notification(member)
    remove_role_group_admin(member)
    
    relationship_to_group(member).destroy

    clear_group_member_relation_cache(member)

    group
  end

  def delete_group_being_invited_notification(member)
    invitation_sender = Member.cached_find(relationship_to_group(member).invite_id)
    NotifyLog.check_update_cancel_invite_friend_to_group_deleted(invitation_sender, member, group)
  end

  def remove_role_group_admin(member)
    member.remove_role :group_admin if group.company?
  end

  def process_approve
    join_group(a_member)
    update_member_group_requesting
    clear_group_member_requesting_cache

    group
  end

  def update_member_group_requesting
    member_group_requesting = group.request_groups.find_by(member_id: a_member.id)
    member_group_requesting.update!(accepted: true, accepter_id: member.id)
  end

  def process_deny
    process_cancel_request(a_member)
    clear_group_member_requesting_cache

    group
  end

  def process_remove
    process_leave(a_member)
  end

  def process_promote
    relationship_to_group(a_member).update!(is_master: true)
    promote_a_member_to_company_admin

    clear_group_member_relation_cache(a_member)
    send_promote_group_admin_notification

    group
  end

  def promote_a_member_to_company_admin
    return unless group.company?
    a_member.add_role :group_admin, group
  end

  def process_demote
    relationship_to_group(a_member).update!(is_master: false)
    demote_a_member_from_company_admin

    clear_group_member_relation_cache(a_member)

    group
  end

  def demote_a_member_from_company_admin
    return unless group.company?
    a_member.remove_role :group_admin, group
  end

  def precess_delete_poll
    poll = Poll.cached_find(poll_id)
    group.poll_groups.find_by(poll_id: poll_id).update!(deleted_at: Time.now, deleted_by_id: member.id)
    poll.destroy if poll.poll_groups == []
    NotifyLog.check_update_poll_deleted(poll)
    NotifyLog.poll_with_group_deleted(poll, group)

    group
  end

  def clear_group_cache_for_member(member)
    FlushCached::Member.new(member).clear_list_groups
  end

  def clear_member_cache_for_group
    FlushCached::Group.new(group).clear_list_members
  end

  def clear_group_member_requesting_cache
    FlushCached::Group.new(group).clear_list_requests
    FlushCached::Member.new(member).clear_list_requesting_groups
  end

  def clear_group_member_relation_cache(member)
    clear_group_cache_for_member(member)
    clear_member_cache_for_group
  end

  def send_invite_friends_to_group_notification(friend_ids)
    InviteFriendToGroupWorker.perform_async(member.id, friend_ids, group.id) unless Rails.env.test?
  end

  def send_poke_invited_friends_to_group_notification(friend_ids)
    PokeInvitedFriendToGroupWorker.perform_async(member.id, friend_ids, group.id) unless Rails.env.test?
  end

  def send_join_group_notification(member)
    JoinGroupWorker.perform_async(member.id, group.id) unless Rails.env.test?
  end

  def send_join_group_request_notification
    RequestGroupWorker.perform_async(member.id, group.id) unless Rails.env.test?
  end

  def send_promote_group_admin_notification
    PromoteAdminWorker.perform_async(member.id, a_member.id, group.id) unless Rails.env.test?
  end

end