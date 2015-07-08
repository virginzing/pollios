class StatsController < ApplicationController

  before_filter :authenticate_admin!, :redirect_unless_admin

  expose(:poll_stats) { @poll_stats }
  expose(:vote_stats) { @vote_stats }
  expose(:user_stats) { @user_stats }
  expose(:group_stats) { @group_stats }
  expose(:total_all_stats) { }

  def dashboard
    filtering = dashboard_params[:filter_by]

    # @poll_stats = PollStats.filter_by(filtering)
    # @vote_stats = VoteStats.filter_by(filtering)

    # @user_stats = UserStats.filter_by(filtering)
    # @group_stats = GroupStats.filter_by(filtering)
    
    @stats_poll_record = Stats::PollRecord.new(filter_by: dashboard_params[:filter_by])
    @stats_vote_record = Stats::VoteRecord.new(filter_by: dashboard_params[:filter_by])
    @stats_user_record = Stats::UserRecord.new(filter_by: dashboard_params[:filter_by])
    @stats_group_record = Stats::GroupRecord.new(filter_by: dashboard_params[:filter_by])

    if filtering == 'yesterday'
      @poll_per_hour = PollStats.poll_per_hour(Date.current - 1.day)
    else
      @poll_per_hour = PollStats.poll_per_hour
    end

  end

  def polls
    @poll_public_all_total = PublicPollSummary.new().get_poll_public_all_total
    @poll_public_citizen_total = PublicPollSummary.new().get_poll_public_citizen_total
    @poll_public_brand_celebrity_total = PublicPollSummary.new().get_poll_public_brand_celebrity_total

    @poll_public_all = PublicPollSummary.new().get_poll_public_all
    @poll_public_citizen = PublicPollSummary.new().get_poll_public_citizen
    @poll_public_brand_celebrity = PublicPollSummary.new().get_poll_public_brand_celebrity
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
