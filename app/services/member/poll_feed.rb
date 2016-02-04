class Member::PollFeed
  include Member::Private::PollFeedAlgorithm

  attr_reader :member, :index

  def initialize(member, options = {})
    @member = member

    @index = options[:index] || 0
  end

  def default_timeline
    cached_overall_timeline_polls
  end

  def unvoted_timeline
    cached_unvoted_timeline_polls
  end

  def public_timeline
    cached_public_timeline_polls
  end

  def friends_timeline
    cached_friends_following_timeline_polls
  end

  def group_timeline
    cached_group_timeline_polls
  end

  def polls_by_page(list)
    pagination(list, index)
  end

  def next_index(list)
    next_cursor_index(list)
  end

  def cached_overall_timeline_polls
    Rails.cache.fetch('current_member/timeline/default') { sort_by_priority(overall_timeline_polls) }
  end

  def cached_unvoted_timeline_polls
    Rails.cache.fetch('current_member/timeline/unvoted') { sort_by_priority(unvoted_timeline_polls) }
  end

  def cached_public_timeline_polls
    Rails.cache.fetch('current_member/timeline/public') { sort_by_priority(public_timeline_polls) }
  end

  def cached_friends_following_timeline_polls
    Rails.cache.fetch('current_member/timeline/friends') { sort_by_priority(friends_following_timeline_polls) }
  end

  def cached_group_timeline_polls
    Rails.cache.fetch('current_member/timeline/group') { sort_by_priority(group_timeline_polls) }
  end

  private

  def overall_timeline_polls
    Poll.unscoped.overall_timeline(member)
  end

  def unvoted_timeline_polls
    Poll.unscoped.unvoted_overall_timeline(member)
  end
  
  def public_timeline_polls
    Poll.unscoped.timeline(member)
      .public_feed
  end

  def friends_following_timeline_polls
    Poll.unscoped.timeline(member)
      .friends_following_feed(member)
  end

  def group_timeline_polls
    Poll.unscoped.timeline(member)
      .group_feed(member)
  end

end