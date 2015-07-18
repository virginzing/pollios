class Stats::UserRecord
  include FilterByStats

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

  def user_active_all
    @user_active_all ||= if filter_by == TODAY
      user_active_range(Date.current, Date.current)
    elsif filter_by == YESTERDAY
      user_active_range(1.days.ago.to_date, 1.days.ago.to_date)
    elsif filter_by == WEEK
      user_active_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      user_active_range(1.month.ago.to_date)
    else
      user_active_total
    end
  end

  def user_passive_all
    @user_passive_all ||= if filter_by == TODAY
      user_passive_range(Date.current, Date.current)
    elsif filter_by == YESTERDAY
      user_passive_range(1.days.ago.to_date, 1.days.ago.to_date)
    elsif filter_by == WEEK
      user_passive_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      user_passive_range(1.month.ago.to_date)
    else
      user_passive_total
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

  def active
    list_members = []
    user_active_all.to_a.each do |member_active|
      list_members << member_active.list_member_ids
    end
    list_members.flatten.uniq.size
  end

  def user_active_total
    list_members = []
    user_active_all.to_a.each do |member_active|
      list_members << member_active.list_member_ids
    end
    list_members.flatten.uniq.size
  end

  def passive
    list_members = []
    user_passive_all.to_a.each do |member_active|
      list_members << member_active.list_member_ids
    end
    list_members.flatten.uniq.size
  end

  def user_passive_total
    list_members = []
    user_passive_all.to_a.each do |member_active|
      list_members << member_active.list_member_ids
    end
    list_members.flatten.uniq.size
  end

  private

  def user_with_range(end_date, start_date = Date.current)
    Member.unscoped.where("date(created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
  end

  def user_total
    Member.unscoped
  end

  def user_active_range(end_date, start_date = Date.current)
    MemberActiveRecord.where(:stats_created_at => { :$gte => end_date, :$lte => start_date }, action: "active")
  end

  def user_active_total
    MemberActiveRecord.where(action: "active")
  end

  def user_passive_range(end_date, start_date = Date.current)
    MemberActiveRecord.where(:stats_created_at => { :$gte => end_date, :$lte => start_date }, action: "passive")
  end

  def user_passive_total
    MemberActiveRecord.where(action: "passive")
  end

end
