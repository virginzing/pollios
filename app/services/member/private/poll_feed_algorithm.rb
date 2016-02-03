module Member::Private::PollFeedAlgorithm

  LIMIT_TIMELINE = 500

  PUBLIC_FEED = 5
  GROUP_FEED = 4
  FRIENDS_FOLLOWING_FEED = 3

  VOTED = 2
  UNVOTED = 4

  RECENT_ACTIVE = 2
  RANGE_CREATED_TIME = 300
  RANGE_CREATED_DATE = 30

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

    # list.sort_by { |poll| [poll[:priority], poll[:created_at]] }.reverse!.take(LIMIT_TIMELINE)
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