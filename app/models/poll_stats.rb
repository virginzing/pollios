class PollStats
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :stats_created_at, type: Date, default: Date.current
  field :amount_poll, type: Integer, default: 0
  field :public_count, type: Integer, default: 0
  field :friend_following_count, type: Integer, default: 0
  field :group_count, type: Integer, default: 0

  index( { stats_created_at: 1 }, { unique: true } )


  def self.create_poll_stats(poll)
    @poll = poll

    @stats_poll = first_or_create_poll_today

    @amount_poll = update_amount_poll

    if @poll.in_group_ids != "0"
      update_stats_group
    else
      if @poll.public
        update_stats_public
      else
        update_stats_friend_following
      end
    end

  end

  def self.update_stats_public
    current_public_count = @stats_poll.public_count
    new_public_count = current_public_count + 1
    @stats_poll.update!(public_count: new_public_count, amount_poll: @amount_poll)
  end

  def self.update_stats_group
    current_group_count = @stats_poll.group_count
    new_group_count = current_group_count + 1
    @stats_poll.update!(group_count: new_group_count, amount_poll: @amount_poll)
  end

  def self.update_stats_friend_following
    current_friend_following_count = @stats_poll.friend_following_count
    new_friend_following_count = current_friend_following_count + 1
    @stats_poll.update!(friend_following_count: new_friend_following_count, amount_poll: @amount_poll)
  end

  def self.update_amount_poll
    current_amount_poll = @stats_poll.amount_poll
    new_amount_poll = current_amount_poll + 1
    new_amount_poll
  end

  def self.poll_per_hour
    new_hash = {}
    @hash_poll = Poll.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).order('created_at asc').group_by(&:hour).each do |k, v|
      new_hash.merge!({ k => v.size })
    end
    new_hash
  end

  ## today or this week or this month

  def self.poll_popular
    Poll.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).order("vote_all desc").limit(10)
  end

  def self.top_voter
    Member.joins(:history_votes).select("members.*, count(history_votes.member_id) as member_vote_count")
          .where("history_votes.created_at BETWEEN ? AND ?", Date.current.beginning_of_day, Date.current.end_of_day)
          .group("history_votes.member_id, members.id")
          .order("member_vote_count desc").limit(10) 
  end

  def self.top_voted_most
    Member.joins(:polls)
          .where("date(polls.created_at + interval '7 hours' ) = ? AND polls.vote_all != 0", Date.current)
          .select("members.*, sum(polls.vote_all) as vote_all, count(polls.member_id) as poll_count")
          .group("members.id")
          .order("vote_all desc")
          .limit(10)
  end


  def self.filter_by(filtering)
    if filtering == 'today' 
      find_stats_poll_today
    else
      find_stats_poll_by(filtering)
    end
  end

  def self.first_or_create_poll_today
    PollStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.find_stats_poll_today
    @poll_stats = PollStats.where(stats_created_at: Date.current).first_or_create!
    convert_stats_poll_today_to_hash
  end

  def self.find_stats_poll_by(condition)
    if condition == 'total'
      split(Poll.all.to_a)
    else
      find_stats_poll_today
    end
  end

  def self.convert_stats_poll_today_to_hash
    {
      :amount => @poll_stats.amount_poll,
      :public => @poll_stats.public_count,
      :friend_following => @poll_stats.friend_following_count,
      :group => @poll_stats.group_count
    }
  end

  def self.split(list_of_poll)
    new_hash = {}

    poll_of_public_count = list_of_poll.collect{|p| p if p.public == true }.compact.count
    poll_of_friend_count = list_of_poll.collect {|p| p if p.public == false && p.in_group_ids == '0' }.compact.count
    poll_of_group_count = list_of_poll.collect {|p| p if p.public == false && p.in_group_ids != '0' }.compact.count

    new_hash.merge!({ 
      :amount => list_of_poll.count,
      :public => poll_of_public_count, 
      :friend_following => poll_of_friend_count,
      :group => poll_of_group_count
    })

    new_hash
  end

  ## total ##

  def self.poll_popular_total
    Poll.all.order("vote_all desc").limit(10)
  end

  def self.top_voter_total
    Member.joins(:history_votes).select("members.*, count(history_votes.member_id) as member_vote_count")
          .group("history_votes.member_id, members.id")
          .order("member_vote_count desc").limit(10) 
  end

  def self.top_voted_most_total
    Member.joins(:polls)
          .select("members.*, sum(polls.vote_all) as vote_all, count(polls.member_id) as poll_count")
          .group("members.id")
          .order("vote_all desc")
          .limit(10)
  end

  ## yesterday ##

  def self.poll_popular_yesterday
    Poll.where("date(created_at + interval '7 hours') = ?", Date.current - 1.day).order("vote_all desc").limit(10)
  end

  def self.top_voter_yesterday
    Member.joins(:history_votes).select("members.*, count(history_votes.member_id) as member_vote_count")
          .where("history_votes.created_at BETWEEN ? AND ?", (Date.current - 1.day).beginning_of_day, (Date.current - 1.day).end_of_day)
          .group("history_votes.member_id, members.id")
          .order("member_vote_count desc").limit(10) 
  end

  def self.top_voted_most_yerterday
    Member.joins(:polls)
          .select("members.*, sum(polls.vote_all) as vote_all, count(polls.member_id) as poll_count")
          .where("date(polls.created_at + interval '7 hours' ) = ? AND polls.vote_all != 0", Date.current - 1.day)
          .group("members.id")
          .order("vote_all desc")
          .limit(10)
  end
end
