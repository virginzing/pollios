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
    @query_all ||= if filter_by == TODAY
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

  def poll_popular
    if filter_by == TODAY
      poll_popular_with_range(Date.current)
    elsif filter_by == YESTERDAY
      poll_popular_with_range(Date.current.yesterday, Date.current.yesterday)
    elsif filter_by == WEEK
      poll_popular_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      poll_popular_with_range(30.days.ago.to_date)
    else
      poll_popular_total
    end
  end

  def top_voter
    if filter_by == TODAY
      top_voter_with_range(Date.current)
    elsif filter_by == YESTERDAY
      top_voter_with_range(Date.current.yesterday, Date.current.yesterday)
    elsif filter_by == WEEK
      top_voter_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      top_voter_with_range(30.days.ago.to_date)
    else
      top_voter_total
    end
  end

  def top_voted
    top_voted = if filter_by == TODAY
      top_voted_with_range(Date.current)
    elsif filter_by == YESTERDAY
      top_voted_with_range(Date.current.yesterday, Date.current.yesterday)
    elsif filter_by == WEEK
      top_voted_with_range(7.days.ago.to_date)
    elsif filter_by == MONTH
      top_voted_with_range(30.days.ago.to_date)
    else
      top_voted_total
    end
    map_to_hash(top_voted)
    # top_voted
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
    Poll.unscoped.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
  end

  def poll_yesterday
    Poll.unscoped.where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
  end

  def poll_total
    Poll.unscoped.all
  end

  def poll_with_range(end_date, start_date = Date.current)
    Poll.where("date(created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
  end

  def poll_popular_with_range(end_date, start_date = Date.current)
    @poll_popular ||= Poll.unscoped.except_series.joins("left join history_votes on history_votes.poll_id = polls.id")
                          .select("polls.*, count(history_votes.poll_id) as votes_count")
                          .where("date(history_votes.created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
                          .group("polls.id")
                          .order("votes_count desc").limit(10)
                          .includes(:member)
  end

  def poll_popular_total
    Poll.unscoped.except_series.joins("left join history_votes on history_votes.poll_id = polls.id")
                  .select("polls.*, count(history_votes.poll_id) as votes_count")
                  .group("polls.id")
                  .order("votes_count desc").limit(10)
                  .includes(:member)
  end

  def top_voter_with_range(end_date, start_date = Date.current)
    Member.joins(:history_votes).select("members.*, count(history_votes.member_id) as member_votes_count")
          .where("date(history_votes.created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
          .group("members.id")
          .order("member_votes_count desc").limit(10)
  end

  def top_voter_total
    Member.joins(:history_votes).select("members.*, count(history_votes.member_id) as member_votes_count")
          .group("members.id")
          .order("member_votes_count desc")
          .limit(10)
  end

  def top_voted_with_range(end_date, start_date = Date.current)
    Poll.joins(:history_votes)
        .where("date(history_votes.created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
        .group("polls.id")
  end

  def top_voted_total
    Poll.joins(:history_votes).group("polls.id")
  end

  def map_to_hash(collections)
    new_hash = []
    collections.count.map do |k, v|
      member = Poll.find(k).member
      new_hash << {
        member_obj: member,
        member_id: member.id,
        poll_id: k,
        vote_count: v
      }
    end
    result = []
    new_hash.each do |hash_member|
      if result.none? {|b| b[:member_id] == hash_member[:member_id] }
        create_hsh = {
          member_obj: hash_member[:member_obj],
          member_id: hash_member[:member_id],
          poll_count: 1,
          vote_count: hash_member[:vote_count]
        }
        result << create_hsh
      else
        result.each do |obj|
          if obj[:member_id] == hash_member[:member_id]
            obj[:poll_count] = obj[:poll_count] + 1
            obj[:vote_count] = obj[:vote_count] + hash_member[:vote_count]
          end
        end
      end
    end

    result.sort {|x,y| y[:vote_count] <=> x[:vote_count] }[0..9]
  end

end
