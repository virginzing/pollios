module Member::Private::GroupActionGuard

  require 'guard_message'

  private

  def can_leave?
    return [false, "You aren't member in #{group.name}."] if not_member(member)
    return [false, "You can't leave #{group.name} company."] if company_group
    [true, nil]
  end

  def can_join?
    return [false, "You are already member of #{group.name}."] if already_member(member)
    return [false, "You already sent join request to #{group.name}."] if already_sent_request(member)
    [true, nil]
  end

  def can_cancel_request?
    return [false, "You are already member of #{group.name}."] if already_member(member)
    return [false, "You don't sent join request to #{group.name}."] if not_exist_join_request(member)
    [true, nil]
  end

  def can_accept_request?
    return [false, "You don't have invitation for #{group.name}."] if not_exist_invite_request(member)
    [true, nil]
  end

  def can_reject_request?
    return [false, "You don't have invitation #{group.name}."] if not_exist_invite_request(member)
    [true, nil]
  end

  def can_invite_friends?
    return [false, "You aren't member in #{group.name}."] if not_member(member)
    return [false, "You can't invite friends to #{group.name} company."] if company_group
    [true, nil]
  end

  def can_poke_invited_friends?
    return [false, "You aren't member in #{group.name}."] if not_member(member)
    return [false, "#{a_member.get_name} is already in #{group.name}."] if already_member(a_member)
    return [false, "#{a_member.get_name} doesn't have invite request to #{group.name}."] if not_exist_invite_request(a_member)
    [true, nil]
  end

  def can_cancel_invite_friends?
    return [false, "#{a_member.get_name} is already in #{group.name}."] if already_member(a_member)
    return [false, "#{a_member.get_name} doesn't have invite request to #{group.name}."] if not_exist_invite_request(a_member)
    return [false, "You aren't invited #{a_member.get_name} to #{group.name}."] if not_invite
    [true, nil]
  end

  def can_approve?
    return [false, GuardMessage::GroupAdminAction.member_already_in_group(a_member, group)] if already_member(a_member)
    return [false, GuardMessage::GroupAdminAction.no_join_request_from_member(a_member, group)] if not_exist_join_request(a_member)
    [true, nil]
  end

  def can_deny?
    return [false, GuardMessage::GroupAdminAction.member_already_in_group(a_member, group)] if already_member(a_member)
    return [false, GuardMessage::GroupAdminAction.no_join_request_from_member(a_member, group)] if not_exist_any_request(a_member)
    [true, nil]
  end

  def can_remove?
    return [false, GuardMessage::GroupAdminAction.member_is_not_in_group(a_member, group)] if not_member(a_member)
    return [false, GuardMessage::GroupAdminAction.cant_remove_yourself] if same_member
    return [false, GuardMessage::GroupAdminAction.member_is_group_creator(a_member)] if group_creator
    [true, nil]
  end

  def can_promote?
    return [false, GuardMessage::GroupAdminAction.member_is_not_in_group(a_member, group)] if not_member(a_member)
    return [false, GuardMessage::GroupAdminAction.member_already_admin(a_member)] if already_admin
    [true, nil]
  end

  def can_demote?
    return [false, GuardMessage::GroupAdminAction.member_is_not_in_group(a_member, group)] if not_member(a_member)
    return [false, GuardMessage::GroupAdminAction.member_is_not_admin(a_member)] if not_admin
    return [false, GuardMessage::GroupAdminAction.member_is_group_creator(a_member)] if group_creator
    [true, nil]
  end

  def can_delete_poll?
    return [false, "This poll isn't exist in group."] if poll_not_in_group
    return [false, 'You are not owner poll.'] if not_authority
    [true, nil]
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
    group.group_type == :company
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

  def poll_not_in_group
    Group::PollList.new(group, viewing_member: member).polls.map(&:id).exclude?(poll_id)
  end

  def not_authority
    !((Poll.cached_find(poll_id).member_id == member.id) || Group::MemberList.new(group).admin?(member))
  end
end
