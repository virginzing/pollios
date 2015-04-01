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

  def clear_list_report_polls
    Rails.cache.delete("member/#{@member.id}/report_polls")
  end

  def clear_list_history_viewed_polls
    Rails.cache.delete("member/#{@member.id}/history_viewed_polls")
  end

  def clear_list_voted_all_polls
    Rails.cache.delete("member/#{@member.id}/voted_all_polls")
  end

end