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
  end

  def deny
  end

  def remove
  end

  def promote
  end

  def demote
  end

  # refactor this into private module later
  private
  def admin_of_group?
    Group::MemberList.new(group).admin?(admin_member)
  end

end