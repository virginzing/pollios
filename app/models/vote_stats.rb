class VoteStats
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :stats_created_at, type: Date, default: Date.current

  field :amount_vote, type: Integer, default: 0
  field :public_count, type: Integer, default: 0
  field :friend_following_count, type: Integer, default: 0
  field :group_count, type: Integer, default: 0

  index( { stats_created_at: 1 }, { unique: true } )

  def self.create_vote_stats(poll)
    @poll = poll

    @stats_vote = first_or_create_vote_today

    @amount_vote = update_amount_vote

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
    current_public_count = @stats_vote.public_count
    new_public_count = current_public_count + 1
    @stats_vote.update!(public_count: new_public_count, amount_vote: @amount_vote)
  end

  def self.update_stats_group
    current_group_count = @stats_vote.group_count
    new_group_count = current_group_count + 1
    @stats_vote.update!(group_count: new_group_count, amount_vote: @amount_vote)
  end

  def self.update_stats_friend_following
    current_friend_following_count = @stats_vote.friend_following_count
    new_friend_following_count = current_friend_following_count + 1
    @stats_vote.update!(friend_following_count: new_friend_following_count, amount_vote: @amount_vote)
  end

  def self.update_amount_vote
    current_amount_vote = @stats_vote.amount_vote
    new_amount_vote = current_amount_vote + 1
    new_amount_vote
  end

  def self.filter_by(filtering)
    if filtering == 'total' 
      split(HistoryVote.joins(:poll))
    elsif filtering == 'yesterday'
      find_stats_vote_yesterday
    elsif filtering == 'week'
      find_stats_vote(7.days.ago.to_date)
    elsif filtering == 'month'
      find_stats_vote(30.days.ago.to_date)
    else
      find_stats_vote_today
    end
  end

  def self.first_or_create_vote_today
    VoteStats.where(stats_created_at: Date.current).first_or_create!
  end

  def self.find_stats_vote_today
    @vote_stats = VoteStats.where(stats_created_at: Date.current).first_or_create!
    convert_stats_vote_to_hash
  end

  def self.find_stats_vote_yesterday
    @vote_stats = VoteStats.where(stats_created_at: Date.current - 1.day).first_or_create!
    convert_stats_vote_to_hash
  end

  def self.find_stats_vote(end_date, start_date = Date.current)
    query = HistoryVote.joins(:poll).where("date(polls.created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date)
    split(query)
  end

  def self.convert_stats_vote_to_hash
    {
      :amount => @vote_stats.amount_vote,
      :public => @vote_stats.public_count,
      :friend_following => @vote_stats.friend_following_count,
      :group => @vote_stats.group_count
    }
  end


  def self.split(list_of_vote)
    new_hash = {}

    vote_public = list_of_vote.where("polls.public = 't'")
    vote_friend_following = list_of_vote.where("polls.public = 'f' AND polls.in_group_ids = '0'")
    vote_in_group = list_of_vote.where("polls.public = 'f' AND polls.in_group_ids != '0'")

    new_hash.merge!({ 
      :amount => list_of_vote.count,
      :public => vote_public.count,
      :friend_following => vote_friend_following.count,
      :group => vote_in_group.count
    })

    new_hash
  end

end
