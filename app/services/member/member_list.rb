class Member::MemberList

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

  def active
    cached_all_friends.select { |a_member| a_member if active_friend_with?(a_member) }
  end

  def friend_request
    cached_all_friends.select { |a_member| a_member if being_requested_friend_by?(a_member) }
  end

  def your_request
    cached_all_friends.select { |a_member| a_member if requesting_friend_with?(a_member) }
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

  private def active?(a_member)
    a_member.member_active == true
  end

  private def friend_with?(a_member)
    a_member.member_status == 1
  end

  private def blocked?(a_member)
    a_member.member_block == true
  end

  private def active_friend_with?(a_member)
    active?(a_member) && !blocked?(a_member) && friend_with?(a_member)
  end

  private def requesting_friend_with?(a_member)
    a_member.member_status == 0 && active?(a_member)
  end

  private def following?(a_member)
    a_member.member_following == true && !friend_with?(a_member) && !a_member.citizen?
  end

  private def followed_by?(a_member)
    a_member.member_following == true && !friend_with?(a_member)
  end

  private def being_requested_friend_by?(a_member)
    a_member.member_status == 2 && active?(a_member)
  end

  private def blocked_friend?(a_member)
    active?(a_member) && blocked?(a_member) && friend_with?(a_member)
  end

  private def ids_for(list)
    list.map(&:id)
  end

  private def ids_include?(ids_list, id)
    ids_for(ids_list).include?(id)
  end

  # TODO: Privatize these two cached-methods.
  def cached_all_friends
    @cached_all_friends ||= Rails.cache.fetch("member/#{member.id}/friends") do
      all_friends
    end
  end

  def cached_all_followers
    @cached_all_followers ||= Rails.cache.fetch("member/#{member.id}/followers") do
      all_followers
    end
  end

  private def all_friends
    @all_friends ||= Member.joins('inner join friends on members.id = friends.followed_id') \
                     .where("friends.follower_id = #{member.id}") \
                     .select('members.*, friends.active as member_active, friends.block as member_block, 
                      friends.status as member_status, friends.following as member_following')
                     .to_a
  end

  private def all_followers
    @all_followers ||= Member.joins('inner join friends on members.id = friends.follower_id') \
                       .where("friends.followed_id = #{member.id}") \
                       .select('members.*, friends.active as member_active, friends.block as member_block, 
                        friends.status as member_status, friends.following as member_following')
                       .to_a
  end

  private def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: member.list_fb_id).order('fullname asc')
  end
  
end