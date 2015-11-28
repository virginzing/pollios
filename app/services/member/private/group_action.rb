module Member::Private::GroupAction

  private

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
      group_type: :normal, # not sure about this, should generalize
      photo_group: group_params[:photo_group],
      description: group_params[:description],
      cover: group_params[:cover],
      cover_preset: group_params[:cover_preset],
      public: group_params[:public].to_b,
      admin_post_only: group_params[:admin_post_only].to_b,
      authorize_invite: :everyone,
      need_approve: group_params[:need_approve]
    }    
  end

  def initialize_new_group
    process_set_group_cover
    process_set_creator_as_admin
    process_create_group_company
    process_clear_member_group_cache
    process_invite_friends
  end

  def process_set_group_cover
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

  def clear_group_cache_for_member
    FlushCached::Member.new(member).clear_list_groups
  end

  def process_invite_friends
  end

end