class Member::MemberList

  attr_reader :member

  def initialize(member, options = {})
    @member = member
    @options = options
  end

  def all
    @all ||= all_friends
  end

  def friends
    cached_all_friends.select { |member| member if friend_with?(member) }
  end

  def followings
    cached_all_friends.select { |member| member if following?(member) }
  end

  def followers
    cached_all_followers.select { |member| member if followed_by?(member) }
  end

  def blocks
    cached_all_friends.select { |member| member if blocked_friend?(member) }
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

  def cached_all_friends
    @cached_all_friends ||= Rails.cache.fetch("member/#{@member.id}/friends") do
      all_friends
    end
  end

  def cached_all_followers
    @cached_all_followers ||= Rails.cache.fetch("member/#{@member.id}/followers") do
      all_followers
    end
  end

  def delete_all_member_caches
    member_cache = FlushCached::Member.new(member)
    member_cache.clear_list_friends
    member_cache.clear_list_followers
  end

  # TODO: safely remove this
  def following_with_no_cache
    all.select { |member| member if following?(member) }
  end

  # TODO: safely remove this
  def follower_with_no_cache
    all_followers.select { |member| member if followed_by?(member) }
  end

  def using_app_via_fb
    @using_app_via_fb ||= query_friend_using_facebook
  end

  def active
    cached_all_friends.select { |member| member if active_friend_with?(member) }
  end

  def active_with_no_cache
    all.select { |member| member if active_friend_with?(member) }
  end

  def friend_request
    cached_all_friends.select { |member| member if being_requested_friend_by?(member) }
  end

  def your_request
    cached_all_friends.select { |member| member if requesting_friend_with?(member) }
  end

  def friend_count
    cached_all_friends.select { |member| member if member.member_active == true && member.member_status == 1 }.to_a.size
  end

  def blocked_by_someone
    Friend.where(followed_id: @member.id, block: true).map(&:follower_id)
  end

  def check_is_friend
    {
      active: active.map(&:id),
      block: blocks.map(&:id),
      friend_request: friend_request.map(&:id),
      your_request: your_request.map(&:id),
      following: followings.map(&:id)
    }
  end

  private

  # query function for relationship between @member and member

  def active?(member)
    member.member_active == true
  end

  def friend_with?(member)
    member.member_status == 1
  end

  def blocked?(member)
    member.member_block == true
  end

  def active_friend_with?(member)
    active?(member) && !blocked?(member) && friend_with?(member)
  end

  def requesting_friend_with?(member)
    member.member_status == 0 && active?(member)
  end

  def following?(member)
    member.member_following == true && !friend_with?(member) && !member.citizen?
  end

  def followed_by?(member)
    member.member_following == true && !friend_with?(member)
  end

  def being_requested_friend_by?(member)
    member.member_status == 2 && active?(member)
  end

  def blocked_friend?(member)
    active?(member) && blocked?(member) && friend_with?(member)
  end

  def ids_for(list)
    list.map(&:id)
  end

  def ids_include?(ids_list, id)
    ids_for(ids_list).include?(id)
  end

  def all_friends
    Member.joins('inner join friends on members.id = friends.followed_id') \
      .where("friends.follower_id = #{@member.id}") \
      .select('members.*, friends.active as member_active, friends.block as member_block, 
        friends.status as member_status, friends.following as member_following')
      .to_a
  end

  def all_followers
    Member.joins('inner join friends on members.id = friends.follower_id') \
      .where("friends.followed_id = #{@member.id}") \
      .select('members.*, friends.active as member_active, friends.block as member_block, 
        friends.status as member_status, friends.following as member_following')
      .to_a
  end

  def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: @member.list_fb_id).order('fullname asc')
  end
  
end