class Member::RequestList

  def initialize(member, options = {})
    @member = member
  end

  def group_requests
    Group.all
  end

  def friend_requests
    ["test"]
  end

  def recommendations
    ["test", "test"]
  end

end