class Member::RequestList

  def initialize(member, options = {})
    @member = member
  end

  def member
    @member
  end

  def friends_incoming
    member_list.friend_request
  end

  def friends_outgoing
    member_list.your_request
  end

  def group_invitations
    group_list.got_invitations
  end

  def group_requests
    group_list.requesting_to_joins
  end

  def admin_groups
    group_list.as_admin_with_requests
  end

  def recommended_friends
    recommendations.friends.sample(20)
  end

  def recommended_groups
    recommendations.groups.sample(10)
  end

  def recommended_officials
    recommendations.officials.sample(5)
  end

  def recommended_via_facebooks
    recommendations.facebooks.sample(10)
  end

private
  def member_list
    @member_list ||= Member::MemberList.new(@member)
  end

  def group_list
    @group_list ||= Member::GroupList.new(@member)
  end

  def recommendations
    @recommendations ||= Recommendation.new(@member)
  end

  def current_member_linkage
    @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
  end

end