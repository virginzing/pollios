class StatsController < ApplicationController

  expose(:poll_stats) { @poll_stats }
  expose(:vote_stats) { @vote_stats }
  expose(:user_stats) { @user_stats }
  expose(:group_stats) { @group_stats }

  def dashboard
    @poll_stats = PollStats.find_stats_poll_today
    @vote_stats = VoteStats.find_stats_vote_today
    @user_stats = UserStats.find_stats_user_today
    @group_stats = GroupStats.find_stats_group_today
  end

  def polls
    
  end

  def votes
    
  end

  def users
    
  end

  def groups
    
  end
end
