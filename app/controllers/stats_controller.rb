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
    
    if filtering == 'today'
      @user_create = UserStats.find_celebrity_or_brand
      @top_voted_most = PollStats.top_voted_most
      @poll_popular = PollStats.poll_popular
      @top_voter = PollStats.top_voter
      @poll_per_hour = PollStats.poll_per_hour
    elsif filtering == 'yesterday'
      @poll_per_hour = PollStats.poll_per_hour(Date.current - 1.day)
      @user_create = UserStats.find_celebrity_or_brand_yesterday
      @top_voted_most = PollStats.top_voted_most_yerterday
      @poll_popular = PollStats.poll_popular_yesterday
      @top_voter = PollStats.top_voter_yesterday
    else
      @user_create = UserStats.find_celebrity_or_brand_total
      @top_voted_most = PollStats.top_voted_most_total
      @poll_popular = PollStats.poll_popular_total
      @top_voter = PollStats.top_voter_total
    end

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
