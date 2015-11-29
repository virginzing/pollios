class Member::GroupAdminAction < Member::GroupAction

  attr_reader :a_member

  def admin_member
    member
  end

  def initialize(admin_member, group, a_member)
    super(admin_member, group)
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

end