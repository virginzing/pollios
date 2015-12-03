module Member::Private::GroupAction

  private

  def member_list
    Group::MemberList.new(group)
  end

  def group_member
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
    process_set_group_cover
    process_set_creator_as_admin
    process_create_group_company
    process_invite_friends(group_params[:friend_ids]) if group_params[:friend_ids].present?

    clear_group_cache_for_member
  end

  def process_set_group_cover
    cover = group_params[:cover]
    cover_group_url = ImageUrl.new(cover)
    return unless cover && cover_group_url.from_image_url?

    group.update_column(:cover_preset, '0')
    group.update_column(:cover, cover_group_url.split_cloudinary_url)
  end

  def process_set_creator_as_admin
    group.group_members.create(member_id: member.id, is_master: true, active: true)
  end

  def process_create_group_company
    return unless member.company.present?
    group.create_group_company(company: member.get_company)
  end

  def process_invite_friends(friend_ids)
    friend_ids = member_list.filter_non_members_from_list(friend_ids)
    
    friend_ids.each do |friend_id|
      group.group_members.create(member_id: friend_id, is_master: false, active: false, invite_id: member.id)
      FlushCached::Member.new(Member.find(friend_id)).clear_list_groups
    end

    clear_member_cache_for_group
    send_invite_friends_to_group_notification(friend_ids)

    group
  end

  def process_join_request
    (invitation? && invite_by_admin?) ? process_join_group : process_sent_join_request

    group
  end

  def process_cancel_request
    group.request_groups.find_by(member_id: member.id).destroy
    process_reject_request if invitation?

    clear_group_member_relation_cache
    clear_request_cache_for_group

    group
  end

  def process_accept_request
    invite_by_admin? ? process_join_group : process_join_request

    group
  end

  def invitation?
    GroupMember.have_request_group?(group, member)
  end

  def invite_by_admin?
    member_list.admin?(Member.find(group_member.invite_id))
  end

  def process_sent_join_request ### PENDING
    group.request_groups.create(member_id: member.id)

    clear_group_member_relation_cache
    clear_request_cache_for_group

    send_join_group_request_notification
  end

  def process_join_group ### IN
    group_member.update!(active: true)

    process_add_member_to_company
    process_set_member_following_company

    clear_group_member_relation_cache

    send_join_group_notification
  end

  def process_add_member_to_company
    return unless group.company? && !group.system_group
    CompanyMember.add_member_to_company(member, group.get_company)
  end

  def process_set_member_following_company
    return unless group.member.company?
    Company::FollowOwnerGroup.new(member, group.member.id).follow!
  end

  def process_reject_request
    delete_group_invitation_notification
    remove_role_group_admin
    
    group_member.destroy

    clear_group_member_relation_cache

    group
  end

  def delete_group_invitation_notification
    a_member = Member.find(group_member.invite_id)
    NotifyLog.check_update_cancel_invite_friend_to_group_deleted(a_member, member, group)
  end

  def remove_role_group_admin
    member.remove_role :group_admin, group if group.company?
  end

  def clear_group_cache_for_member
    FlushCached::Member.new(member).clear_list_groups
  end

  def clear_member_cache_for_group
    FlushCached::Group.new(group).clear_list_members
  end

  def clear_request_cache_for_group
    FlushCached::Group.new(group).clear_list_requests
  end

  def clear_group_member_relation_cache
    clear_group_cache_for_member
    clear_member_cache_for_group
  end

  def send_invite_friends_to_group_notification(friend_ids)
    InviteFriendToGroupWorker.perform_async(member.id, friend_ids, group.id) unless Rails.env.test?
  end

  def send_join_group_notification
    JoinGroupWorker.perform_async(member.id, group.id) unless Rails.env.test?
  end

  def send_join_group_request_notification
    RequestGroupWorker.perform_async(member.id, group.id) unless Rails.env.test?
  end

end