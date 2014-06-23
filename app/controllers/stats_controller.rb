class StatsController < ApplicationController

  expose(:poll_stats) { @poll_stats }
  expose(:vote_stats) { @vote_stats }
  expose(:user_stats) { @user_stats }
  expose(:group_stats) { @group_stats }
  expose(:total_all_stats) { }

  def dashboard
    filtering = dashboard_params[:filter_by]

    @poll_stats = PollStats.filter_by(filtering)
    @vote_stats = VoteStats.find_stats_vote_today

    @user_stats = UserStats.find_stats_user_today
    @group_stats = GroupStats.find_stats_group_today
    @poll_per_hour = PollStats.poll_per_hour
    @poll_popular = PollStats.poll_popular

    @top_voter = PollStats.top_voter
  end

  def polls
    
  end

  def votes
    
  end

  def users
    
  end

  def groups
    
  end

  private

  def dashboard_params
    params.permit(:filter_by)
  end
end
