class FlushCached::Member
  def initialize(member)
    @member = member
  end

  def clear_list_friends
    Member::ListFriend.new(@member).cached_all_friends.each do |member|
      Rails.cache.delete("member/#{member.id}/friends")
    end
  end

  def clear_one_friend
    Rails.cache.delete("member/#{@member.id}/friends")
  end

  def clear_one_follower
    Rails.cache.delete("member/#{@member.id}/follower")
  end


  def clear_list_groups
    Rails.cache.delete("member/#{@member.id}/groups")
  end

end