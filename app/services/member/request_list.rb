class Member::RequestList

  attr_reader :member, :options

  def initialize(member, options = {})
    @member = member
    @options = options

    reset_new_request_count if options[:clear_new_request_count]
  end

  def recent_friends
    friends = cached_recent_friends

    clear_cached_recent_friends if options[:clear_new_request_count]

    friends
  end

  def recent_groups
    groups = cached_recent_groups

    clear_cached_recent_groups if options[:clear_new_request_count]

    groups
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

  def cached_recent_friends
    Rails.cache.fetch("members/#{member.id}/requests/recent_friends") do
      Member.joins('INNER JOIN member_recent_requests ON members.id = member_recent_requests.recent_id')
        .where("member_recent_requests.member_id = #{member.id}")
        .to_a
    end
  end

  def cached_recent_groups
    Rails.cache.fetch("members/#{member.id}/requests/recent_groups") do
      Group.joins('INNER JOIN member_recent_requests ON groups.id = member_recent_requests.recent_id')
        .where("member_recent_requests.member_id = #{member.id}")
        .to_a
    end
  end

  def clear_cached_recent_friends
    MemberRecentRequest.where(member_id: member.id, recent_type: 'Member').each(&:destroy)
    FlushCached::Member.new(member).clear_list_recent_friends
  end

  def clear_cached_recent_groups
    MemberRecentRequest.where(member_id: member.id, recent_type: 'Group').each(&:destroy)
    FlushCached::Member.new(member).clear_list_recent_groups
  end
end