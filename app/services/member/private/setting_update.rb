module Member::Private::SettingUpdate

  private

  def process_update_profile
    update_name
    update_description
    update_avatar
    update_cover_image
    update_cover_preset

    clear_member_cached
    clear_member_cached_for_friends_and_followings

    member
  end

  def update_name
    return unless params_profile[:name]

    NotifyLog.update_changed_member_name(member, params_profile[:name], member.fullname)
    member.update!(fullname: params_profile[:name])

    update_first_signup_to_false
  end

  def update_description
    return unless params_profile[:description]

    member.update!(description: params_profile[:description])
  end

  def update_avatar
    return unless params_profile[:avatar]

    remove_avatar

    member.update_column(:avatar, ImageUrl.new(params_profile[:avatar]).split_cloudinary_url)
  end

  def remove_avatar
    member.remove_avatar!
    member.save!
  end

  def update_cover_image
    return unless params_profile[:cover]

    remove_cover_image

    member.update_column(:cover, ImageUrl.new(params_profile[:cover]).split_cloudinary_url)

    remove_cover_preset
  end

  def remove_cover_preset
    return if member.cover_preset == 0

    member.update!(cover_preset: '0')
  end

  def update_cover_preset
    return unless params_profile[:cover_preset]

    member.update!(cover_preset: params_profile[:cover_preset])

    remove_cover_image
  end

  def remove_cover_image
    return if member.get_cover_image.empty?

    member.remove_cover!
    member.save!
  end

  def process_update_facebook_connection
    update_facebook_id 
    update_facebook_friend_ids
  end

  def update_facebook_id
    fb_id = params_facebook[:fb_id] == '' ? nil : params_facebook[:fb_id]

    return member.update!(fb_id: fb_id, sync_facebook: true) if fb_id

    member.update!(fb_id: fb_id, list_fb_id: [], sync_facebook: false)
  end

  def update_facebook_friend_ids
    return unless params_facebook[:list_fb_id]

    member.update!(list_fb_id: params_facebook[:list_fb_id])
  end

  def process_update_public_id
    member.update(public_id: params_public_id[:public_id])
    fail ExceptionHandler::UnprocessableEntity, member.errors.messages[:public_id].first unless member.valid?

    member.save!

    clear_member_cached
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
    member.update!(notification: params_notifications.except(:member_id))
  end

  def update_first_signup_to_false
    return unless member.first_signup

    member.update!(first_signup: false)
  end

  def clear_member_cached_for_friends_and_followings
    FlushCached::Member.new(member).clear_list_friends_and_followings_all_members
  end

  def clear_member_cached
    Rails.cache.delete(['Member', member.id])
  end

end