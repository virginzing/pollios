class HomeController < ApplicationController

  before_action :signed_user, only: [:dashboard]
  before_action :only_company_account, only: [:dashboard]

  def dashboard
    @init_poll ||= PollOfGroup.new(current_member, current_member.get_company.groups, options_params)
    @poll_latest_list = @init_poll.get_poll_of_group_company.limit(5)

    @poll_popular_list = @init_poll.get_poll_of_group_company.where("vote_all != 0").order("vote_all desc").limit(5)
    render 'home/dashboard_company'
  end

  def index
    @popular_poll = PopularPoll.in_total
    render layout: 'homepage'
  end

  private

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

end
