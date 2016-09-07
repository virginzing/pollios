class Member::MemberAction
  include Member::Private::MemberActionGuard
  include Member::Private::MemberAction

  attr_reader :member, :a_member

  def initialize(member, a_member, options = {})
    @member = member
    @a_member = a_member
    @options = options
  end

  def add_friend
    can_add_friend, message = can_add_friend?
    fail ExceptionHandler::UnprocessableEntity, message unless can_add_friend

    # return follow unless a_member.citizen?

    process_friend_requests_transaction 
  end

  def unfriend
    can_unfriend, message = can_unfriend?
    fail ExceptionHandler::UnprocessableEntity, message unless can_unfriend

    process_unfriend_request
  end

  def add_close_friend
    # not using at this moment
  end

  def remove_close_friend
    # not using at this moment
  end

  def follow
    can_follow, message = can_follow?
    fail ExceptionHandler::UnprocessableEntity, message unless can_follow

    process_following
  end

  def unfollow
    can_unfollow, message = can_unfollow?
    fail ExceptionHandler::UnprocessableEntity, message unless can_unfollow

    process_unfollow
  end

  def accept_friend_request
    can_accept_friend_request, message = can_accept_friend_request?
    fail ExceptionHandler::UnprocessableEntity, message unless can_accept_friend_request

    process_accept_friend_request
  end

  def deny_friend_request
    can_deny_friend_request, message = can_deny_friend_request?
    fail ExceptionHandler::UnprocessableEntity, message unless can_deny_friend_request

    process_deny_friend_request
  end

  def cancel_friend_request
    can_cancel_friend_request, message = can_cancel_friend_request?
    fail ExceptionHandler::UnprocessableEntity, message unless can_cancel_friend_request
      
    process_cancel_friend_request
  end

  def block
    can_block, message = can_block?
    fail ExceptionHandler::UnprocessableEntity, message unless can_block

    process_block
  end

  def unblock
    can_unblock, message = can_unblock?
    fail ExceptionHandler::UnprocessableEntity, message unless can_unblock

    process_unblock
  end

  def report(reason_message, and_block)
    can_report, message = can_report?
    fail ExceptionHandler::UnprocessableEntity, message unless can_report

    process_report(reason_message)
    block if and_block
  end
end