module Member::Private::SettingUpdate

  private

  def process_update_profile
    update_name
    update_description
    update_avatar
    update_cover
    update_cover_preset

    clear_member_cached_for_friends

    member
  end

  def update_name
    return unless params_profile[:name]
    NotifyLog.edit_message_that_change_name(member, params_profile[:name], member.fullname)
    member.update!(fullname: params_profile[:name])
  end

  def update_description
    return unless params_profile[:description]
    member.update!(description: params_profile[:description])
  end

  def update_avatar
    return unless params_profile[:avatar]
    member.update_column(:avatar, ImageUrl.new(params_profile[:avatar]).split_cloudinary_url)
  end

  def update_cover
    return unless params_profile[:cover]
    member.update_column(:cover, ImageUrl.new(params_profile[:cover]).split_cloudinary_url)
    return unless member.cover_preset == 0
    member.update!(cover_preset: '0')
  end

  def update_cover_preset
    return unless params_profile[:cover_preset]
    member.update!(cover_preset: params_profile[:cover_preset])
    return unless member.cover.present?
    member.remove_cover!
  end

  def process_update_public_id
    member.update(public_id: params_public_id[:public_id])
    fail ExceptionHandler::UnprocessableEntity, 'Public ID has already been take' unless member.valid?

    member.save!
  end

  def process_update_personal
    update_birthday
    updata_gender
    member.update!(update_personal: true)

    member
  end

  def update_birthday
    return unless params_personal[:birthday]
    member.update!(birthday: params_personal[:birthday])
  end

  def updata_gender
    return unless params_personal[:gender]
    member.update!(gender: params_personal[:gender])
  end
  
  def process_update_notifications
  end

  def clear_member_cached_for_friends
    FlushCached::Member.new(member).clear_list_friends_all_members
  end

end