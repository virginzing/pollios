class Stats::GroupRecord
  include FilterByStats
  
  def initialize(options = {})
    @options = options
  end

  def filter_by
    @options[:filter_by] || TODAY
  end

  def query_all
    @query_all ||= if filter_by == TODAY
      group_with_range(Date.current, Date.current)
    elsif filter_by == YESTERDAY
      group_with_range(1.days.ago.to_date, 1.days.ago.to_date)
    elsif filter_by == WEEK
      group_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      group_with_range(1.month.ago.to_date)
    else
      group_total
    end
  end

  def count
    query_all.size
  end

  def total
    @total ||= group_total.size
  end

  def public
    query_all.select{|e| e if e.public }.size  
  end

  def private
    query_all.select{|e| e unless e.public }.size
  end

  private

  def group_with_range(end_date, start_date = Date.current)
    Group.where("date(created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
  end

  def group_total
    Group.all
  end

end