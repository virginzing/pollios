class Group::CheckUserInGroup

  def initialize(member, group)
    @member = member
    @group = group
  end

  def member_list_group
    @member_list_group ||= Member::GroupList.new(@member).active.map(&:id)
  end

  def exists?
    member_list_group.include?(@group.id) ? true : false
  end

  def raise_error_not_in_group
    fail ExceptionHandler::UnprocessableEntity, "You're not in group." unless exists?
  end

end