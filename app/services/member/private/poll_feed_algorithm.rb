module Member::Private::PollFeedAlgorithm

  LIMIT_TIMELINE = 500
  LIMIT_POLL = 30

  PUBLIC_FEED = 5
  GROUP_FEED = 4
  FRIENDS_FOLLOWING_FEED = 3

  VOTED = 2
  UNVOTED = 4

  RECENT_ACTIVE = 2
  RANGE_CREATED_TIME = 300
  RANGE_CREATED_DATE = 30

  def pagination(list, index)
    index == 0 ? new_pagination(list) : next_pagination(list, index)
  end

  def new_pagination(list)
    Rails.cache.delete('current_member/timeline/default')
    list = cached_overall_timeline_polls
    list = list[0..(LIMIT_POLL - 1)]
    fucking_next_index = next_cursor_index(list)

    [polls: list, next_index: fucking_next_index]
  end

  def next_pagination(list, index)
    index = cached_overall_timeline_polls.map(&:id).index(index) + 1
    list = list[index..(LIMIT_POLL + index)]
    fucking_next_index = next_cursor_index(list)

    [polls: list, next_index: fucking_next_index]
  end

  def next_cursor_index(list)
    # TODO: cached_timeline(type)
    return 0 if cached_overall_timeline_polls.count < LIMIT_POLL
    return 0 if list.count < LIMIT_POLL
    return 0 if list.last.id == cached_overall_timeline_polls.last.id
    list.last.id
  end

  def sort_by_priority(list)
    calculate_priority(list)
  end

  def calculate_priority(list)
    list.each do |poll|
      adjust = poll.priority
      adjust += ((feed_priority(poll) + vote_status(poll) + recent_active(poll) + range_created_time(poll)) * 
                range_created_date(poll))

      poll.priority = adjust
    end

    list.order('polls.priority DESC').order('polls.created_at DESC').limit(LIMIT_TIMELINE)
  end

  def feed_priority(poll)
    if poll.public
      PUBLIC_FEED
    elsif poll.in_group
      GROUP_FEED
    else
      FRIENDS_FOLLOWING_FEED
    end
  end

  def vote_status(poll)
    Member::PollInquiry.new(member, poll).voted? ? VOTED : VOTED
  end

  def recent_active(poll)
    (poll.updated_at > 2.days.ago) ? RECENT_ACTIVE : 0
  end

  def range_created_time(poll)
    compare_time = RANGE_CREATED_TIME - ((Time.zone.now - poll.created_at) / 60.00).round

    (compare_time >= 0) ? ((RANGE_CREATED_TIME - compare_time) / 30.00).round : 0
  end

  def range_created_date(poll)
    compare_date = RANGE_CREATED_DATE - (Time.zone.now.to_date - poll.created_at.to_date).to_i
  
    (compare_date >= 0) ? compare_date : 1
  end
  
end