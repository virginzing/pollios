class StatsController < ApplicationController

  expose(:poll_stats) { @poll_stats }
  expose(:vote_stats) { @vote_stats }
  expose(:user_stats) { @user_stats }
  expose(:group_stats) { @group_stats }
  expose(:total_all_stats) { }

  def dashboard
    filtering = dashboard_params[:filter_by]

    @poll_stats = PollStats.filter_by(filtering)
    @vote_stats = VoteStats.filter_by(filtering)

    @user_stats = UserStats.filter_by(filtering)
    @group_stats = GroupStats.filter_by(filtering)
    
    @poll_per_hour = PollStats.poll_per_hour
    @poll_popular = PollStats.poll_popular

    @top_voter = PollStats.top_voter

    @user_create = UserStats.find_celebrity_or_brand

    @top_voted_most = UserStats.top_voted_most
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
