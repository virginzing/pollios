class Stats::UserRecord

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
      user_with_range(Date.current, Date.current)
    elsif filter_by == YESTERDAY
      user_with_range(1.days.ago.to_date, 1.days.ago.to_date)
    elsif filter_by == WEEK
      user_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      user_with_range(1.month.ago.to_date)
    else
      user_total
    end
  end

  def count
    query_all.size
  end

  def total
    @total ||= user_total.size
  end

  def citizen
    query_all.select{|e| e if e.citizen? }.size
  end

  def celebrity
    query_all.select{|e| e if e.celebrity? }.size
  end

  def company
    query_all.select{|e| e if e.company? }.size
  end

  private

  def user_with_range(end_date, start_date = Date.current)
    Member.unscoped.where("date(created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
  end

  def user_total
    Member.unscoped
  end
  
end


  def vote_with_range(end_date, start_date = Date.current)
    HistoryVote.joins(:poll).where("(date(polls.created_at + interval '7 hours') BETWEEN ? AND ?) AND polls.series = 'f'", end_date, start_date)
  end

  def vote_total
    HistoryVote.joins(:poll).where("polls.series = 'f'")
  end