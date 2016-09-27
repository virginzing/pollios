class Group::MemberInquiry

  attr_reader :group_member_list

  def initialize(group)
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

  def inviter(member)
    equal_member_method = member.method(:==)

    inviter_id = group_member_list.all
      .bsearch(&equal_member_method)
      .member_invite_id

    Member.find(inviter_id)
  end

  def members?
    group_member_list.members.present?
  end

  def admins?
    group_member_list.admins.present?
  end

  def all?
    group_member_list.all.present?
  end

end
