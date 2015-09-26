class FlushCached::Member
  def initialize(member)
    @member = member
  end

  def clear_list_friends_all_members
    Member::MemberList.new(@member).cached_all_friends.each do |member|
      Rails.cache.delete("member/#{member.id}/friends")
    end
  end

  def clear_list_friends
    Rails.cache.delete("member/#{@member.id}/friends")
  end

  def clear_list_followers
    Rails.cache.delete("member/#{@member.id}/followers")
  end

  def clear_list_groups
    Rails.cache.delete("member/#{@member.id}/groups")
  end

  def clear_list_report_polls
    Rails.cache.delete("member/#{@member.id}/report_polls")
  end

  def clear_list_report_comments
    Rails.cache.delete("member/#{@member.id}/report_comments")
  end

  def clear_list_history_viewed_polls
    Rails.cache.delete("member/#{@member.id}/history_viewed_polls")
  end

  def clear_list_voted_all_polls
    Rails.cache.delete("member/#{@member.id}/voted_all_polls")
  end

  def clear_list_watched_polls
    Rails.cache.delete("member/#{@member.id}/watch_polls")
  end

end