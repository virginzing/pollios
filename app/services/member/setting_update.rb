class Member::SettingUpdate
  include Member::Private::SettingUpdate

  attr_reader :member, :params_profile, :params_public_id, :params_personal, :params_notifications

  def initialize(member)
    @member = member
  end

  def profile(params)
    @params_profile = params
    process_update_profile
  end

  def public_id(params)
    @params_public_id = params
    process_update_public_id
  end

  def personal(params)
    @params_personal = params
    process_update_personal
  end

  def notifications(params)
    @params_notifications = params
    process_update_notifications
  end

end