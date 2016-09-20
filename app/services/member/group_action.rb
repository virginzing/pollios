class Member::GroupAction
  include Member::Private::GroupActionGuard
  include Member::Private::GroupAction

  attr_reader :member, :group, :group_params, :a_member, :poll_id, :code

  def initialize(member, group = nil, options = {})
    @member = member
    @group = group
    @options = options
  end

  def create(params = {})
    @group_params = params
    process_create_group
  end

  def leave
    can_leave, message = can_leave?
    fail ExceptionHandler::UnprocessableEntity, message unless can_leave
      
    process_leave(member)
  end

  def join
    can_join, message = can_join?
    fail ExceptionHandler::UnprocessableEntity, message unless can_join
      
    process_join_request
  end

  def join_with_secret_code(code)
    @code = code

    can_join_with_secret_code, message = can_join_with_secret_code?
    fail ExceptionHandler::UnprocessableEntity, message unless can_join_with_secret_code
      
    process_join_with_secret_code
  end

  def cancel_request
    can_cancel_request, message = can_cancel_request?
    fail ExceptionHandler::UnprocessableEntity, message unless can_cancel_request

    process_cancel_request
  end

  def accept_invitation
    can_accept_invitation, message = can_accept_invitation?
    fail ExceptionHandler::UnprocessableEntity, message unless can_accept_invitation
      
    process_accept_invitation
  end

  def reject_invitation
    can_reject_invitation, message = can_reject_invitation?
    fail ExceptionHandler::UnprocessableEntity, message unless can_reject_invitation
      
    process_reject_invitation
  end

  def invite(friend_ids)
    can_invite_friends, message = can_invite_friends?
    fail ExceptionHandler::UnprocessableEntity, message unless can_invite_friends

    process_invite_friends(friend_ids)
  end

  def poke_invited(a_member)
    @a_member = a_member
    can_poke_invited_friends, message = can_poke_invited_friends?
    fail ExceptionHandler::UnprocessableEntity, message unless can_poke_invited_friends

    process_poke_invited_friends
  end

  def cancel_invite(a_member)
    @a_member = a_member
    can_cancel_invite_friends, message = can_cancel_invite_friends?
    fail ExceptionHandler::UnprocessableEntity, message unless can_cancel_invite_friends

    process_cancel_invite_friends
  end

  def delete_poll(poll_id)
    @poll_id = poll_id
    can_delete_poll, message = can_delete_poll?
    fail ExceptionHandler::UnprocessableEntity, message unless can_delete_poll

    process_delete_poll
  end

end
