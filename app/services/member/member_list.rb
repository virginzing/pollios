class Member::MemberList

  def initialize(member, options = {})
    @member = member
  end

  def all
    @all ||= all_friend
  end

  # def friends
  #   @cached_all_friends ||= cached_friends
  # end

  def friends
    cached_all_friends.select { |user| user if user.member_status == 1 }
  end

  def followings
    cached_all_friends.select{ |user| user if user.member_following == true && user.member_status != 1 }.select{| member | member unless member.citizen? }
  end

  def followers
    cached_followers.select{ |user| user if user.member_following == true && user.member_status != 1}
  end

  def blocks
    cached_all_friends.select{ |user| user if user.member_active == true && user.member_block == true && user.member_status == 1 }
  end

  def social_linkage_ids
    friends_ids = ids_for(friends)
    requesting_ids = ids_for(your_request)
    being_requested_ids = ids_for(friend_request)
    followings_ids = ids_for(followings)
    blocks_ids = ids_for(blocks)

    hash = { :friends_ids => friends_ids, 
             :requesting_ids => requesting_ids,
             :being_requested_ids => being_requested_ids,
             :followings_ids => followings_ids,
             :blocks_ids => blocks_ids }
    hash
  end

  def cached_all_friends
    @cached_all_friends ||= cached_friends
  end

  def cached_followers
    @cached_followers ||= cached_followers
  end

  def following_with_no_cache
    all.select{ |user| user if user.member_following == true && user.member_status != 1 }.select{| member | member unless member.citizen? }
  end

  def follower_with_no_cache
    all_followers.select{|user| user if user.member_following == true && user.member_status != 1}
  end

  def using_app_via_fb
    @using_app_via_fb ||= query_friend_using_facebook
  end

  def active
    cached_all_friends.select{ |user| user if user.member_active == true && user.member_block == false && user.member_status == 1 }
  end

  def active_with_no_cache
    all.select{|user| user if user.member_active == true && user.member_block == false && user.member_status == 1 }
  end

  def friend_request
    cached_all_friends.select{ |user| user if user.member_status == 2 && user.member_active == true }
  end

  def your_request
    cached_all_friends.select{ |user| user if user.member_status == 0 && user.member_active == true }
  end

  def friend_count
    cached_all_friends.select{ |user| user if user.member_active == true && user.member_status == 1 }.to_a.size
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

  def ids_for(list)
    list.map(&:id)
  end

  def ids_include?(ids_list, id)
    ids_for(ids_list).include?(id)
  end

  def all_friend
    Member.joins("inner join friends on members.id = friends.followed_id") \
          .where("friends.follower_id = #{@member.id}") \
          .select("members.*, friends.active as member_active, friends.block as member_block, friends.status as member_status, friends.following as member_following")

  end

  def all_followers
    Member.joins("inner join friends on members.id = friends.follower_id") \
          .where("friends.followed_id = #{@member.id}") \
          .select("members.*, friends.active as member_active, friends.block as member_block, friends.status as member_status, friends.following as member_following")
  end

  def query_friend_using_facebook
    Member.with_status_account(:normal).where(fb_id: @member.list_fb_id).order("fullname asc")
  end

  def cached_friends
    Rails.cache.fetch("member/#{@member.id}/friends") do
      all_friend.to_a
    end
  end

  def cached_followers
    Rails.cache.fetch("member/#{@member.id}/followers") do
      all_followers.to_a
    end
  end
  
end