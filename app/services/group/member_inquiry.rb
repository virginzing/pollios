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

  def members?
    group_member_list.members.present?
  end

  def admins?
    group_member_list.admins.present?
  end

  def all?
    group_member_list.all.present?
  end

  def has_all?(members)
    if members.is_a?(Array)
      (members - group_member_list.all).empty?
    else
      has?(members)
    end
  end

  def has_any?(members)
    if members.is_a?(Array)
      (group_member_list.all - members) != group_member_list.all
    else
      has?(members)
    end
  end

end