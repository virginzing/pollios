class Member::MemberList
  include Member::Private::MemberList
  include Member::FriendRelationHelper

  attr_reader :member

  def initialize(member, options = {})
    @member = member
    @options = options
  end

  def social_linkage_ids
    { 
      friends_ids: ids_for(friends), 
      requesting_ids: ids_for(your_request),
      being_requested_ids: ids_for(friend_request),
      followings_ids: ids_for(followings),
      blocks_ids: ids_for(blocks)
    }
  end

  def already_friend_with?(a_member)
    ids_include?(active_friends, a_member.id)
  end

  def already_sent_request_to?(a_member)
    ids_include?(outgoing_requests, a_member.id)
  end

  def friends
    cached_all_friends.select { |a_member| a_member if friend_with?(a_member) }
  end

  def followings
    cached_all_friends.select { |a_member| a_member if following?(a_member) }
  end

  def followers
    cached_all_followers.select { |a_member| a_member if followed_by?(a_member) }
  end

  def blocks
    cached_all_friends.select { |a_member| a_member if blocked_friend?(a_member) }
  end

  def active_friends
    cached_all_friends.select { |a_member| a_member if active_friend_with?(a_member) }
  end

  def incoming_requests
    cached_all_friends.select { |a_member| a_member if being_requested_friend_by?(a_member) }
  end

  def outgoing_requests
    cached_all_friends.select { |a_member| a_member if requesting_friend_with?(a_member) }
  end

  # NOTE: For debuggings and loggings Member::MemberAction's methods
  def friends_ids
    ids_for(friends).sort
  end

  def outgoing_requests_ids
    ids_for(outgoing_requests).sort
  end

  # NOTE: The following getters are for compatibility with legacy code
  # TODO: Remove them to use proper getter methods above
  def active
    active_friends
  end

  def friend_request
    incoming_requests
  end

  def your_request
    outgoing_requests
  end

  def friend_count
    cached_all_friends.count { |a_member| a_member if active?(a_member) && friend_with?(a_member) }
  end

  def blocked_by_someone
    Friend.where(followed_id: member.id, block: true).map(&:follower_id)
  end

  # TODO: safely remove this
  def following_with_no_cache
    all_friends.select { |a_member| a_member if following?(a_member) }
  end

  # TODO: safely remove this
  def follower_with_no_cache
    all_followers.select { |a_member| a_member if followed_by?(a_member) }
  end

  def active_with_no_cache
    all_friends.select { |a_member| a_member if active_friend_with?(a_member) }
  end

  def using_app_via_fb
    @using_app_via_fb ||= query_friend_using_facebook
  end

  # TODO: Consider moving this into future's LEGACY namespace
  def check_is_friend
    {
      active: active.map(&:id),
      block: blocks.map(&:id),
      friend_request: friend_request.map(&:id),
      your_request: your_request.map(&:id),
      following: followings.map(&:id)
    }
  end

  def delete_all_member_caches
    member_cache = FlushCached::Member.new(member)
    member_cache.clear_list_friends
    member_cache.clear_list_followers
  end

  # TODO: Privatize these two cached-methods.
  def cached_all_friends
    Rails.cache.fetch("member/#{member.id}/friends") do
      all_friends
    end
  end

  def cached_all_followers
    Rails.cache.fetch("member/#{member.id}/followers") do
      all_followers
    end
  end
  
end