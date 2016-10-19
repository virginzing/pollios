module Member::Private::GroupUpdate

  private

  def process_update_details
    update_name
    update_description
    update_cover_image
    update_cover_preset

    clear_members_and_group_relation_cached

    group
  end

  def update_name
    return unless params_details[:name]

    group.update!(name: params_details[:name])
  end

  def update_description
    return unless params_details[:description]

    group.update!(description: params_details[:description])
  end

  def update_cover_image
    return unless params_details[:cover]

    group.update_column(:cover, ImageUrl.new(params_details[:cover]).split_cloudinary_url)

    remove_cover_preset
  end

  def remove_cover_preset
    return if group.cover_preset == 0

    group.update!(cover_preset: '0')
  end

  def update_cover_preset
    return unless params_details[:cover_preset]

    group.update!(cover_preset: params_details[:cover_preset])

    remove_cover_image
  end

  def remove_cover_image
    return unless group.cover.present?

    group.remove_cover!
    group.save!
  end

  def process_update_privacy
    group.update(params_privacy)
    fail ExceptionHandler::UnprocessableEntity, 'Public ID has already been take' unless group.valid?

    group.save!

    approve_all unless group.need_approve?

    group
  end

  def approve_all
    Group::MemberList.new(group).requesting.map do |member|
      Member::GroupAdminAction.new(admin_member, group, member).approve
    end
  end

  def clear_members_and_group_relation_cached
    FlushCached::Group.new(group).clear_list_group_all_member_in_group
    FlushCached::Group.new(group).clear_list_members
  end

end