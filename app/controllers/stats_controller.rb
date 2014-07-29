class StatsController < ApplicationController

  before_filter :authenticate_admin!, :redirect_unless_admin

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
    
    if filtering == 'total'
      @user_create = UserStats.find_celebrity_or_brand_total
      @top_voted_most = PollStats.top_voted_most_total
      @poll_popular = PollStats.poll_popular_total
      @top_voter = PollStats.top_voter_total
    elsif filtering == 'yesterday'
      @poll_per_hour = PollStats.poll_per_hour(Date.current - 1.day)
      @user_create = UserStats.find_celebrity_or_brand_yesterday
      @top_voted_most = PollStats.top_voted_most_yerterday
      @poll_popular = PollStats.poll_popular_yesterday
      @top_voter = PollStats.top_voter_yesterday
    elsif filtering == 'week'
      @user_create = UserStats.find_celebrity_or_brand(7.days.ago.to_date)
      @top_voted_most = PollStats.top_voted_most(7.days.ago.to_date)
      @poll_popular = PollStats.poll_popular(7.days.ago.to_date)
      @top_voter = PollStats.top_voter(7.days.ago.to_date)
    elsif filtering == 'month'
      @user_create = UserStats.find_celebrity_or_brand(30.days.ago.to_date)
      @top_voted_most = PollStats.top_voted_most(30.days.ago.to_date)
      @poll_popular = PollStats.poll_popular(30.days.ago.to_date)
      @top_voter = PollStats.top_voter(30.days.ago.to_date)
    else
      @user_create = UserStats.find_celebrity_or_brand(Date.current)
      @poll_per_hour = PollStats.poll_per_hour
      @top_voted_most = PollStats.top_voted_most(Date.current)
      @poll_popular = PollStats.poll_popular(Date.current)
      @top_voter = PollStats.top_voter(Date.current)
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
