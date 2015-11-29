class Member::GroupAction
  include Member::Private::GroupActionGuard
  include Member::Private::GroupAction

  attr_reader :member, :group, :group_params

  def initialize(member, group = nil, options = {})
    @member = member
    @group = group
    @options = options
  end

  def create(params = {})
    @group_params = params
    process_create_group
  end

  def join
  end

  def leave
  end

  def accept_request
  end

  def reject_request
  end

  def cancel_request
  end

  def invite(friend_ids)
  end

end
