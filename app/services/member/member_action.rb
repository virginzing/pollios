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

    process_friend_requests_transaction
  end

  def unfriend
    can_unfriend, message = can_unfriend?
    fail ExceptionHandler::UnprocessableEntity, message unless can_unfriend

    process_unfriend_request
  end

  def add_close_friend
  end

  def remove_close_friend
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

  def accept_friend
  end

  def deny_friend
  end

  def block
  end

  def unblock
  end

end