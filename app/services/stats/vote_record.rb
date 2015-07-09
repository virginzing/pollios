class Stats::VoteRecord
  
  TODAY = 'today'
  YESTERDAY = 'yesterday'
  WEEK = 'week'
  MONTH = 'month'
  TOTAL = 'total'

  def initialize(options = {})
    @options = options
  end

  def filter_by
    @options[:filter_by] || TODAY
  end

  def query_all
    @query_all ||= if filter_by == TODAY
      vote_with_range(Date.current, Date.current)
    elsif filter_by == YESTERDAY
      vote_with_range(1.days.ago.to_date, 1.days.ago.to_date)
    elsif filter_by == WEEK
      vote_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      vote_with_range(1.month.ago.to_date)
    else
      vote_total
    end
  end

  def count
    query_all.size
  end

  def total
    @total ||= vote_total.size
  end

  def poll_public
    query_all.where("polls.public = 't'").size
  end

  def poll_friend_following
    query_all.where("polls.public = 'f' AND polls.in_group = 'f'").size
  end

  def poll_group
    query_all.where("polls.public = 'f' AND polls.in_group = 't'").size
  end

  private

  def vote_with_range(end_date, start_date = Date.current)
    HistoryVote.joins(:poll).where("(date(history_votes.created_at + interval '7 hours') BETWEEN ? AND ?) AND polls.series = 'f'", end_date, start_date)
  end

  def vote_total
    HistoryVote.joins(:poll).where("polls.series = 'f'")
  end

  
end