class ListFriend
  def initialize(member)
    @member = member
  end

  def all
    @all ||= all_friend
  end

  def cached_all_friends
    @cached_all_friends ||= cached_friends
  end

  def cached_follower
    @cached_follower ||= cached_follower
  end

  def active
    cached_all_friends.select{|user| user if user.member_active == true && user.member_block == false && user.member_status == 1  }
  end

  def block
    cached_all_friends.select{|user| user if user.member_active == true && user.member_block == true && user.member_status == 1  }
  end

  def friend_request
    cached_all_friends.select{|user| user if user.member_status == 2 && user.member_active == true }
  end

  def your_request
    cached_all_friends.select{|user| user if user.member_status == 0 && user.member_active == true }
  end

  def following
    cached_all_friends.select{|user| user if user.member_following == true && user.member_status != 1 }
  end

  def follower
    cached_follower.select{|user| user if user.member_following == true && user.member_status != 1}
  end

  private

  def all_friend
    Member.joins("inner join friends on members.id = friends.followed_id")
          .where("friends.follower_id = #{@member.id}")
          .select("members.*, friends.active as member_active, friends.block as member_block, friends.status as member_status, friends.following as member_following")

  end

  def all_follower
    Member.joins("inner join friends on members.id = friends.follower_id") \
          .where("friends.followed_id = #{@member.id}") \
          .select("members.*, friends.active as member_active, friends.block as member_block, friends.status as member_status, friends.following as member_following")
  end

  def cached_friends
    Rails.cache.fetch("member/#{@member.id}/friends") do
      all_friend.to_a
    end
  end

  def cached_follower
    Rails.cache.fetch("member/#{@member.id}/follower") do
      all_follower.to_a
    end
  end
  
end