class Member::RequestList

  def initialize(member, options = {})
    @member = member
  end

  def member
    @member
  end

  def incoming_requests
    member_list.friend_request
  end

  def outgoing_requests
    member_list.your_request
  end

  def group_invitations
  end

  def group_requests
  end

  def member_list
    @member_list ||= Member::MemberList.new(@member)
  end

  def current_member_linkage
    @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
  end

end