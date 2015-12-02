module Member::Private::GroupAction

  private

  def member_list
    Group::MemberList.new(group)
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

  def clear_group_cache_for_member
    FlushCached::Member.new(member).clear_list_groups
  end

  def clear_member_cache_for_group
    FlushCached::Group.new(group).clear_list_members
  end

  def send_invite_friends_to_group_notification(friend_ids)
    InviteFriendToGroupWorker.perform_async(member.id, friend_ids, group.id) unless Rails.env.test?
  end

end