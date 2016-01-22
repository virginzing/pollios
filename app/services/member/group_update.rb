class Member::GroupUpdate < Member::GroupAdminAction
  include Member::Private::GroupUpdate

  attr_reader :params_details, :params_privacy

  def initialize(admin_member, group)
    super(admin_member, group)
  end

  def details(params)
    @params_details = params
    process_update_details
  end

  def privacy(params)
    @params_privacy = params
    process_update_privacy
  end

end