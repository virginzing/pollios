class Stats::PollRecord

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
    if filter_by == TODAY
      poll_today
    elsif filter_by == YESTERDAY
      poll_yesterday
    elsif filter_by == WEEK
      poll_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      poll_with_range(1.month.ago.to_date)
    else
      poll_total
    end
  end

  def count
    query_all.size
  end

  def total
    poll_total.size
  end

  def poll_public
    query_all.select{|e| e if e.public }.size
  end

  def poll_friend_following
    query_all.select{|e| e if (e.public == false && e.in_group == false) }.size
  end

  def poll_group
    query_all.select{|e| e if e.in_group }.size
  end


  private

  def poll_today
    @poll_today ||= Poll.unscoped.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day)
  end

  def poll_yesterday
    @poll_yesterday ||= Poll.unscoped.where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
  end

  def poll_total
    @poll_total ||= Poll.unscoped.all
  end

  def poll_with_range(end_date, start_date = Time.zone.now.to_date)
    @poll = Poll.where("date(created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
  end
  
  
end