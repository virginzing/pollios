class StatsController < ApplicationController

  before_filter :authenticate_admin!, :redirect_unless_admin

  expose(:poll_stats) { @poll_stats }
  expose(:vote_stats) { @vote_stats }
  expose(:user_stats) { @user_stats }
  expose(:group_stats) { @group_stats }
  expose(:total_all_stats) { }

  def dashboard
    filtering = dashboard_params[:filter_by]
    
    if filtering.present?
      fail ExceptionHandler::WebNotFound unless FilterByStats::LIST_OF_FILTER.include?(filtering)
    else
      redirect_to stats_dashboard_path(filter_by: FilterByStats::TODAY)
    end

    @stats_poll_record = Stats::PollRecord.new(filter_by: dashboard_params[:filter_by])
    @stats_vote_record = Stats::VoteRecord.new(filter_by: dashboard_params[:filter_by])
    @stats_user_record = Stats::UserRecord.new(filter_by: dashboard_params[:filter_by])
    @stats_group_record = Stats::GroupRecord.new(filter_by: dashboard_params[:filter_by])
  end

  # NOTE: CURRENTLY UNUSED. NO LINK.
  def polls
    poll_summary = Stats::PublicPolls.new()

    @poll_public_all_total = poll_summary.get_poll_public_all_total
    @poll_public_citizen_total = poll_summary.get_poll_public_citizen_total
    @poll_public_brand_celebrity_total = poll_summary.get_poll_public_brand_celebrity_total

    @poll_public_all = poll_summary.get_poll_public_all
    @poll_public_citizen = poll_summary.get_poll_public_citizen
    @poll_public_brand_celebrity = poll_summary.get_poll_public_brand_celebrity
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
