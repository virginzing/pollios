class Member::GroupAdminAction < Member::GroupAction

  attr_reader :a_member

  def admin_member
    member
  end

  def initialize(admin_member, group, a_member)
    super(admin_member, group)
    fail ExceptionHandler::UnprocessableEntity, 'Only group admin allows' unless admin_of_group?
    @a_member = a_member
  end

  def approve
    can_approve, message = can_approve?
    fail ExceptionHandler::UnprocessableEntity, message unless can_approve
      
    process_approve
  end

  def deny
    can_deny, message = can_deny?
    fail ExceptionHandler::UnprocessableEntity, message unless can_deny
      
    process_deny
  end

  def remove
    can_remove, message = can_remove?
    fail ExceptionHandler::UnprocessableEntity, message unless can_remove
      
    process_remove
  end

  def promote
    can_promote, message = can_promote?
    fail ExceptionHandler::UnprocessableEntity, message unless can_promote

    process_promote
  end

  def demote
    can_demote, message = can_demote?
    fail ExceptionHandler::UnprocessableEntity, message unless can_demote

    process_demote
  end

  # refactor this into private module later
  private
  def admin_of_group?
    member_listing_service.admin?(admin_member)
  end

end