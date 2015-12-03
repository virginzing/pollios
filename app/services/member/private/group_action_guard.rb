module Member::Private::GroupActionGuard

  private

  def can_leave?
    return false, "You are not in #{group.name}." if not_member
    return false, "You can't leave #{group.name} company." if company_group
    [true, '']
  end

  def can_join_request?
    return false, "You are already member of #{group.name}." if already_member
    return false, "You already sent join request to #{group.name}." if already_sent_request
    [true, '']
  end

  def can_cancel_request?
    return false, "You are already member of #{group.name}." if already_member
    return false, "You don't sent join request to #{group.name}." if not_exist_join_request
    [true, '']
  end

  def can_accept_request?
    return false, "You don't have invitation for #{group.name}." if not_exist_invite_request
    [true, '']
  end

  def can_reject_request?
    return false, "You don't have invitation #{group.name}." if not_exist_invite_request
    [true, '']
  end

  def can_invite_friends?
    return false, "You are not in #{group.name}." if not_member
    return false, "You can't invite friends to #{group.name} company." if company_group
    [true, '']
  end

  def already_member
    member_list.active?(member)
  end

  def already_sent_request
    member_list.requesting?(member)
  end

  def not_exist_join_request
    !already_sent_request
  end

  def not_member
    !already_member
  end

  def company_group
    group.group_type == 'company'
  end

  def not_exist_invite_request
    !member_list.pending?(member)
  end

end