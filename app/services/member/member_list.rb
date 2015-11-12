class Member::MemberList

  attr_reader :member

  def initialize(member, options = {})
    @member = member
    @options = options
  end

  def all
    @all ||= all_friend
  end

  def friends
    cached_all_friends.select { |member| member if is_friend_with(member) }
  end

  def followings
    cached_all_friends.select { |member| member if is_following(member) }
  end

  def followers
    cached_followers.select { |member| member if is_followed_by(member) }
  end

  def blocks
    cached_all_friends.select { |member| member if is_blocking(member) }
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
    @cached_all_friends ||= cached_friends
  end

  # TODO: rename this or cached_all_friends to match one another
  def cached_followers
    @cached_followers ||= cached_all_followers
  end

  # TODO: safely remove this
  def following_with_no_cache
    all.select { |member| member if is_following(member) }
  end

  # TODO: safely remove this
  def follower_with_no_cache
    all_followers.select { |member| member if is_followed_by(member) }
  end

  def using_app_via_fb
    @using_app_via_fb ||= query_friend_using_facebook
  end

  def active
    cached_all_friends.select { |member| member if is_active_friend_with(member) }
  end

  def active_with_no_cache
    all.select { |member| member if is_active_friend_with(member) }
  end

  def friend_request
    cached_all_friends.select { |member| member if is_being_requested_by(member) }
  end

  def your_request
    cached_all_friends.select { |member| member if is_requesting(member) }
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

  # private

  def is_active(member)
    member.member_active == true
  end

  def is_friend_with(member)
    member.member_status == 1
  end

  def is_active_friend_with(member)
    is_active(member) && member.member_block == false && is_friend_with(member)
  end

  def is_requesting(member)
    member.member_status == 0 && is_active(member)
  end

  def is_following(member)
    member.member_following == true && !is_friend_with(member) && !member.citizen?
  end

  def is_followed_by(member)
    member.member_following == true && !is_friend_with(member)
  end

  def is_being_requested_by(member)
    member.member_status == 2 && is_active(member)
  end

  def is_blocking(member)
    is_active(member) && member.member_block == true && is_friend_with(member)
  end

  def ids_for(list)
    list.map(&:id)
  end

  def ids_include?(ids_list, id)
    ids_for(ids_list).include?(id)
  end

  def all_friend
    Member.joins('inner join friends on members.id = friends.followed_id') \
      .where("friends.follower_id = #{@member.id}") \
      .select('members.*, friends.active as member_active, friends.block as member_block, friends.status as member_status, friends.following as member_following')
  end

  def all_followers
    Member.joins('inner join friends on members.id = friends.follower_id') \
      .where("friends.followed_id = #{@member.id}") \
      .select('members.*, friends.active as member_active, friends.block as member_block, friends.status as member_status, friends.following as member_following')
  end

  def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: @member.list_fb_id).order('fullname asc')
  end

  def cached_friends
    Rails.cache.fetch("member/#{@member.id}/friends") do
      all_friend.to_a
    end
  end

  def cached_all_followers
    Rails.cache.fetch("member/#{@member.id}/followers") do
      all_followers.to_a
    end
  end
  
end