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

    @stats_vote = find_stats_vote_today

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

  def self.find_stats_vote_today
    VoteStats.where(stats_created_at: Date.current).first_or_create!
  end

end
