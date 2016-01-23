module Member::Private::GroupActionGuard

  private

  def can_leave?
    return false, "You aren't member in #{group.name}." if not_member(member)
    return false, "You can't leave #{group.name} company." if company_group
    [true, '']
  end

  def can_join?
    return false, "You are already member of #{group.name}." if already_member(member)
    return false, "You already sent join request to #{group.name}." if already_sent_request(member)
    [true, '']
  end

  def can_cancel_request?
    return false, "You are already member of #{group.name}." if already_member(member)
    return false, "You don't sent join request to #{group.name}." if not_exist_join_request(member)
    [true, '']
  end

  def can_accept_request?
    return false, "You don't have invitation for #{group.name}." if not_exist_invite_request(member)
    [true, '']
  end

  def can_reject_request?
    return false, "You don't have invitation #{group.name}." if not_exist_invite_request(member)
    [true, '']
  end

  def can_invite_friends?
    return false, "You aren't member in #{group.name}." if not_member(member)
    return false, "You can't invite friends to #{group.name} company." if company_group
    [true, '']
  end

  def can_cancel_invite_friends?
    return false, "#{a_member.get_name} is already in #{group.name}." if already_member(a_member)
    return [false, "#{a_member.get_name} doesn't have invite request to #{group.name}."] if not_exist_invite_request(a_member)
    return [false, "You aren't invited #{a_member.get_name} to #{group.name}."] if not_invite
    [true, '']
  end

  def can_approve?
    return false, "#{a_member.get_name} doesn't sent join request to #{group.name}." if not_exist_join_request(a_member)
    return false, "#{a_member.get_name} is already in #{group.name}." if already_member(a_member)
    [true, '']
  end

  def can_deny?
    return false, "#{a_member.get_name} is already in #{group.name}." if already_member(a_member)
    return false, "#{a_member.get_name} doesn't have any request to #{group.name}." if not_exist_any_request(a_member)
    [true, '']
  end

  def can_remove?
    return false, "#{a_member.get_name} isn't member in #{group.name}." if not_member(a_member)
    return false, "You can't remove yourself." if same_member
    return false, "#{a_member.get_name} is group creator." if group_creator
    [true, '']
  end

  def can_promote?
    return false, "#{a_member.get_name} isn't member in #{group.name}." if not_member(a_member)
    return false, "#{a_member.get_name} is already admin." if already_admin
    [true, '']
  end

  def can_demote?
    return false, "#{a_member.get_name} isn't member in #{group.name}." if not_member(a_member)
    return false, "#{a_member.get_name} isn't admin." if not_admin
    return false, "#{a_member.get_name} is group creator." if group_creator
    [true, '']
  end

  def same_member
    member.id == a_member.id
  end

  def already_member(member)
    member_listing_service.active?(member)
  end

  def already_sent_request(member)
    member_listing_service.requesting?(member)
  end

  def not_exist_join_request(member)
    !already_sent_request(member)
  end

  def not_member(member)
    !already_member(member)
  end

  def company_group
    group.group_type == 'company'
  end

  def not_exist_invite_request(member)
    !member_listing_service.pending?(member)
  end

  def not_invite
    group.group_members.find_by(member_id: a_member.id).invite_id != member.id
  end

  def not_exist_any_request(member)
    not_exist_join_request(member) && not_exist_invite_request(member)
  end

  def already_admin
    member_listing_service.admin?(a_member)
  end

  def not_admin
    !already_admin
  end

  def group_creator
    group.member_id == a_member.id
  end

end