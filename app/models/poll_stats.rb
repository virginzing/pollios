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

    @stats_poll = find_stats_poll_today

    @amount_poll = update_amount_poll

    if @poll.in_group_ids != '0'
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

  def self.find_stats_poll_today
    PollStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.poll_per_hour
    new_hash = {}
    @hash_poll = Poll.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).order('created_at asc').group_by(&:hour).each do |k, v|
      new_hash.merge!({ k => v.size })
    end
    new_hash
  end

  def self.poll_popular
    Poll.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).order("vote_all desc").limit(5)
  end

  def self.top_voter
    Member.joins(:history_votes).select("members.*, count(history_votes.member_id) as member_vote_count")
          .where("history_votes.created_at BETWEEN ? AND ?", DateTime.now.beginning_of_day, DateTime.now.end_of_day)
          .group("history_votes.member_id")
          .order("member_vote_count desc")
          .limit(10) 
  end

end
