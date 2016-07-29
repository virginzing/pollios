class Member::RequestList

  attr_reader :member

  def initialize(member, options = {})
    @member = member

    reset_new_request_count if options[:clear_new_request_count]
  end

  def friends_incoming
    member_listing.friend_request
  end

  def friends_outgoing
    member_listing.your_request
  end

  def group_invitations
    group_listing.got_invitations
  end

  def group_requests
    group_listing.requesting_to_joins
  end

  def group_admins
    group_listing.as_admin_with_requests
  end

  def recommended_friends
    recommendations.friends.sample(10)
  end

  def recommended_groups
    recommendations.groups.sample(10)
  end

  def recommended_officials
    recommendations.officials.sample(10)
  end

  def recommended_via_facebooks
    recommendations.facebooks.sample(10)
  end

  private

  def member_listing
    @member_listing ||= Member::MemberList.new(member)
  end

  def group_listing
    @group_listing ||= Member::GroupList.new(member)
  end

  def recommendations
    @recommendations ||= Member::Recommendation.new(member)
  end

  def reset_new_request_count    
    member.request_count = 0
    member.save!
  end

end