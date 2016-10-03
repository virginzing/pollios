class Group::MemberInquiry < Group::MemberList

  attr_reader :group_member_list

  def initialize(group)
    super(group)

    @group_member_list = Group::MemberList.new(group)
  end

  def member?(member)
    group_member_list.members.include?(member)
  end

  def admin?(member)
    group_member_list.admins.include?(member)
  end

  def active?(member)
    group_member_list.active.include?(member)
  end

  def requesting?(member)
    group_member_list.requesting.include?(member)
  end

  def pending?(member)
    group_member_list.pending.include?(member)
  end

  def inviter_of(member)
    equal_member_method = member.method(:==)

    inviter_id = group_member_list
                 .all
                 .find(&equal_member_method)
                 .member_invite_id

    return nil unless inviter_id.present?

    Member.find(inviter_id)
  end

  def has_member?
    group_member_list.members.present?
  end

  def has_admin?
    group_member_list.admins.present?
  end

  def has_requesting?
    group_member_list.requesting.present?
  end

  def has_active?
    group_member_list.active.present?
  end

end
