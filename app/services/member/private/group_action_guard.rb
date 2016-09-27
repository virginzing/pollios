module Member::Private::GroupActionGuard

  require 'guard_message'

  private

  def can_leave?
    return [false, GuardMessage::GroupAction.member_is_not_in_group(group)] if not_member?(member)
    return [false, GuardMessage::GroupAction.cannot_leave_company_group(group)] if company_group?
    [true, nil]
  end

  def can_join?
    return [false, GuardMessage::GroupAction.member_already_in_group(group)] if already_member?(member)
    return [false, GuardMessage::GroupAction.already_sent_request(group)] if already_sent_request?(member)
    [true, nil]
  end

  def can_join_with_secret_code?
    return [false, GuardMessage::GroupAction.invalid_secret_code] if invalid_secret_code?
    return [false, GuardMessage::GroupAction.already_used_secret_code] if already_used_secret_code?
    return [false, GuardMessage::GroupAction.member_already_in_group(group)] if already_member_in_group_by_secret_code?

    [true, nil]
  end

  def can_promote_self?
    return [false, GuardMessage::GroupAction.member_is_not_in_group(group)] if not_member?(member)
    return [false, GuardMessage::GroupAction.cannot_promote_self] if group_already_had_admins?

    [true, nil]
  end

  def can_cancel_request?
    return [false, GuardMessage::GroupAction.member_already_in_group(group)] if already_member?(member)
    return [false, GuardMessage::GroupAction.no_join_request(group)] if not_exist_join_request?(member)
    [true, nil]
  end

  def can_accept_invitation?
    return [false, GuardMessage::GroupAction.no_invitation(group)] if not_exist_invite_request?(member)
    [true, nil]
  end

  def can_reject_invitation?
    return [false, GuardMessage::GroupAction.no_invitation(group)] if not_exist_invite_request?(member)
    [true, nil]
  end

  def can_invite_friends?
    return [false, GuardMessage::GroupAction.member_is_not_in_group(group)] if not_member?(member)
    return [false, GuardMessage::GroupAction.cannot_invite_friends_to_company_group(group)] if company_group?
    [true, nil]
  end

  def can_poke_invited_friends?
    return [false, GuardMessage::GroupAction.member_is_not_in_group(group)] if not_member?(member)
    return [false, GuardMessage::GroupAction.member_already_in_group(group, a_member)] if already_member?(a_member)
    return [false, GuardMessage::GroupAction.member_not_have_invite_request(group, a_member)] if not_exist_invite_request?(a_member)
    [true, nil]
  end

  def can_cancel_invite_friends?
    return [false, GuardMessage::GroupAction.member_already_in_group(group, a_member)] if already_member?(a_member)
    return [false, GuardMessage::GroupAction.member_not_have_invite_request(group, a_member)] if not_exist_invite_request?(a_member)
    return [false, GuardMessage::GroupAction.you_have_not_invite_member(group, a_member)] if not_invite?
    [true, nil]
  end

  def can_approve?
    return [false, GuardMessage::GroupAdminAction.member_already_in_group(a_member, group)] if already_member?(a_member)
    return [false, GuardMessage::GroupAdminAction.no_join_request_from_member(a_member, group)] if not_exist_join_request?(a_member)
    [true, nil]
  end

  def can_deny?
    return [false, GuardMessage::GroupAdminAction.member_already_in_group(a_member, group)] if already_member?(a_member)
    return [false, GuardMessage::GroupAdminAction.no_join_request_from_member(a_member, group)] if not_exist_any_request?(a_member)
    [true, nil]
  end

  def can_remove?
    return [false, GuardMessage::GroupAdminAction.member_is_not_in_group(a_member, group)] if not_member?(a_member)
    return [false, GuardMessage::GroupAdminAction.cant_remove_yourself] if same_member?(member, a_member)
    return [false, GuardMessage::GroupAdminAction.member_is_group_creator(a_member)] if group_creator?
    [true, nil]
  end

  def can_promote?
    return [false, GuardMessage::GroupAdminAction.member_is_not_in_group(a_member, group)] if not_member?(a_member)
    return [false, GuardMessage::GroupAdminAction.member_already_admin(a_member)] if already_admin?
    [true, nil]
  end

  def can_demote?
    return [false, GuardMessage::GroupAdminAction.member_is_not_in_group(a_member, group)] if not_member?(a_member)
    return [false, GuardMessage::GroupAdminAction.member_is_not_admin(a_member)] if not_admin?
    return [false, GuardMessage::GroupAdminAction.member_is_group_creator(a_member)] if group_creator?
    [true, nil]
  end

  def can_delete_poll?
    return [false, "This poll isn't exist in group."] if poll_not_in_group
    return [false, 'You are not owner poll.'] if not_authority
    [true, nil]
  end

  def group_member_inquiry
    Group::MemberInquiry.new(group)
  end

  def same_member?(member, a_member)
    member.id == a_member.id
  end

  def already_member?(member)
    group_member_inquiry.active?(member)
  end

  def not_member?(member)
    !already_member?(member)
  end

  def already_sent_request?(member)
    group_member_inquiry.requesting?(member)
  end

  def not_exist_join_request?(member)
    !already_sent_request?(member)
  end

  def not_exist_invite_request?(member)
    !group_member_inquiry.pending?(member)
  end

  def not_exist_any_request?(member)
    not_exist_join_request?(member) && not_exist_invite_request?(member)
  end

  def company_group?
    group[:group_type] == 1
  end

  def not_invite?(inviter, member)
    group_member_inquiry.inviter(a_member) != member
  end

  def already_admin?
    group_member_inquiry.admin?(a_member)
  end

  def not_admin?
    !already_admin?
  end

  def group_already_had_admins?
    group_member_inquiry.admins?
  end

  def group_creator?
    group.member_id == a_member.id
  end

  def poll_not_in_group
    Group::PollList.new(group, viewing_member: member).polls.map(&:id).exclude?(poll_id)
  end

  def not_authority
    !((Poll.cached_find(poll_id).member_id == member.id) || group_member_inquiry.admin?(member))
  end

  def secret_code
    @secret_code ||= InviteCode.find_by(code: code)
  end

  def invalid_secret_code?
    secret_code.nil?
  end

  def already_used_secret_code?
    secret_code.used
  end

  def already_member_in_group_by_secret_code?
    @group = Group.cached_find(secret_code.group_id)

    group_member_inquiry.active?(member)
  end
end
