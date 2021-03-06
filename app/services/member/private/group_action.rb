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
    group = Group.new(new_group_params_hash)

    group.save!

    group
  end

  def new_group_params_hash
    {
      member_id: member.id,
      name: group_params[:name],
      description: group_params[:description],
      cover: group_params[:cover],
      cover_preset: group_params[:cover_preset],
      need_approve: group_params[:need_approve]
    }
  end

  def initialize_new_group
    generate_public_id
    set_cover
    set_creator_as_admin
    create_group_company
    process_invite_friends(group_params[:friend_ids]) if group_params[:friend_ids].present?

    clear_group_member_relation_cache(member)
  end

  def generate_public_id
    group.assign_attributes(public_id: unique_group_public_id(group))
  end

  def unique_group_public_id(group)
    joined_name = group.name.scan(/[a-zA-Z0-9_.]+/).join
    public_id = joined_name.first(20)

    public_id = 'group' + group.id.to_s if group.public_id.nil? || group.public_id.empty?
    public_id = joined_name.first(10) + Time.now.to_i.to_s while Group.exists?(public_id: public_id)

    public_id
  end

  def set_cover
    if uploaded_cover_given?
      set_uploaded_cover
    elsif !cover_preset_given?
      set_random_cover_preset
    end
  end

  def set_uploaded_cover
    cover = group_params[:cover]
    cover_group_url = ImageUrl.new(cover)

    group.update_column(:cover, cover_group_url.split_cloudinary_url)
  end

  def set_random_cover_preset
    group.cover_preset = random_cover_preset
  end

  def random_cover_preset
    rand(1..26)
  end

  def uploaded_cover_given?
    group_params[:cover] && ImageUrl.new(group_params[:cover]).from_image_url?
  end

  def cover_preset_given?
    group_params[:cover_preset].present? && !group_params[:cover_preset].zero?
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

  def process_poke_invited_friends
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
    group.destroy unless Group::MemberInquiry.new(group).has_active?

    group
  end

  def process_join_request
    being_invited_by_admin_or_trigger? ? join_group(member) : ask_join_request
  end

  def process_join_with_secret_code
    used_secret_code

    group.group_members.create!(member_id: member.id, is_master: false, active: true)
    add_member_to_company(member)
    clear_group_member_relation_cache(member)

    group
  end

  def used_secret_code
    secret_code.update!(used: true)
    member.member_invite_codes.create!(invite_code_id: secret_code.id)
  end

  def process_cancel_request(member = @member)
    group.request_groups.find_by(member_id: member.id).destroy if being_sent_join_request?(member)
    process_reject_invitation(member) if being_invited?(member)

    remove_update_log_cancel_request(member)

    clear_group_member_relation_cache(member)
    clear_group_member_requesting_cache(member)

    group
  end

  def process_accept_invitation
    process_join_request
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
    return true if group_member_inquiry.admin?(Member.cached_find(relationship_to_group(member).invite_id))
    member.id == relationship_to_group(member).invite_id
  end

  def ask_join_request
    group.need_approve ? sent_join_request : join_group(member)
  end

  def sent_join_request
    group.request_groups.create(member_id: member.id)

    clear_group_member_relation_cache(member)
    clear_group_member_requesting_cache(member)

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

    trigger_pending_vote_for(member, group)

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

  def trigger_pending_vote_for(member, group)
    pending_votes = PendingVote.where(member_id: member.id).pending_for('Group', group.id)

    pending_votes.map do |pending_vote|
      Member::PollAction.new(pending_vote.member, pending_vote.poll).trigger_pending_vote
    end
  end

  def process_reject_invitation(member = @member)
    delete_group_being_invited_notification(member)
    remove_role_group_admin(member)

    relationship_to_group(member).destroy

    clear_group_member_relation_cache(member)

    group
  end

  def delete_group_being_invited_notification(member)
    invitation_sender = Member.cached_find(relationship_to_group(member).invite_id)

    remove_update_log_cancel_invitation_to_group(invitation_sender, member, group)
  end

  def remove_role_group_admin(member)
    member.remove_role :group_admin if group.company?
  end

  def process_approve
    join_group(a_member)
    update_member_group_requesting
    clear_group_member_requesting_cache(a_member)

    send_approve_join_group_request_notification

    group
  end

  def update_member_group_requesting
    member_group_requesting = group.request_groups.find_by(member_id: a_member.id)
    member_group_requesting.update!(accepted: true, accepter_id: member.id)
  end

  def process_deny
    process_cancel_request(a_member)
    clear_group_member_requesting_cache(a_member)

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

  def process_delete_poll
    poll = Poll.cached_find(poll_id)

    delete_poll_in_group
    delete_poll_from_system(poll) if poll_not_in_groups?(poll)

    group
  end

  def delete_poll_in_group
    PollGroup.find_by(poll_id: poll_id, group_id: group.id).update!(deleted_at: Time.now, deleted_by_id: member.id)
  end

  def poll_not_in_groups?(poll)
    poll.poll_groups.empty?
  end

  def delete_poll_from_system(poll)
    poll.destroy
    create_company_group_action_tracking_delete_poll
    remove_update_log_delete_poll
  end

  def create_company_group_action_tracking_delete_poll
    member.activity_feeds.create!(action: :delete, trackable: poll, group_id: group.id) if group.company?
  end

  def clear_group_cache_for_member(member)
    FlushCached::Member.new(member).clear_list_groups
  end

  def clear_member_cache_for_group
    FlushCached::Group.new(group).clear_list_members
  end

  def clear_group_member_requesting_cache(member)
    FlushCached::Group.new(group).clear_list_requests
    FlushCached::Member.new(member).clear_list_requesting_groups
  end

  def clear_group_member_relation_cache(member)
    clear_group_cache_for_member(member)
    clear_member_cache_for_group
  end

  def send_invite_friends_to_group_notification(friend_ids)
    # InviteFriendToGroupWorker.perform_async(member.id, friend_ids, group.id)
    V1::Group::InviteWorker.perform_async(member.id, friend_ids, group.id)
  end

  def send_poke_invited_friends_to_group_notification(friend_ids)
    # PokeInvitedFriendToGroupWorker.perform_async(member.id, friend_ids, group.id)
    V1::Group::InviteWorker.perform_async(member.id, friend_ids, group.id, poke: true)
  end

  def send_join_group_notification(member)
    # JoinGroupWorker.perform_async(member.id, group.id)
    V1::Group::JoinWorker.perform_async(member.id, group.id)
  end

  def send_join_group_request_notification
    # RequestGroupWorker.perform_async(member.id, group.id)
    V1::Group::JoinRequestWorker.perform_async(member.id, group.id)
  end

  def send_promote_group_admin_notification
    # PromoteAdminWorker.perform_async(member.id, a_member.id, group.id)
    V1::Group::PromoteAdminWorker.perform_async(member.id, a_member.id, group.id)
  end

  def send_approve_join_group_request_notification
    V1::Group::ApproveWorker.perform_async(member.id, a_member.id, group.id)
  end

  def remove_update_log_delete_poll
    V1::Poll::DeleteWorker.perform_async(poll_id)
  end

  def remove_update_log_cancel_invitation_to_group(invitation_sender, member)
    V1::Group::CancelInvitationWorker.perform_async(invitation_sender.id, member.id, group.id)
  end

  def remove_update_log_cancel_request(member)
    V1::Group::CancelRequestWorker.perform_async(member.id, group.id)
  end

end