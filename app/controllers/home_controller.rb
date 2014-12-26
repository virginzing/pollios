class HomeController < ApplicationController
  before_action :signed_user, only: [:dashboard]
  
  # before_action :only_brand_or_company_account, only: [:dashboard]

  def dashboard

    @poll_latest_list = Poll.where(member_id: @current_member.id, series: false).order("created_at desc").limit(5)
    @poll_popular_list = Poll.where("member_id = #{@current_member.id} AND vote_all != 0 AND series = 'f'").order("vote_all desc").limit(5)
    
    if current_member.brand?
      @questionnaire = PollSeries.where(member_id: current_member.id).last
      render 'home/dashboard_brand'
    else
      @init_poll ||= PollOfGroup.new(current_member, current_member.get_company.groups, options_params)
      @poll_latest_list = @init_poll.get_poll_of_group_company.limit(5)

      @poll_popular_list = @init_poll.get_poll_of_group_company.where("vote_all != 0").order("vote_all desc").limit(5)
      render 'home/dashboard_company'
    end
  end
  
  def index
    @popular_poll = PopularPoll.in_total
    
    # render layout: 'homepage'
    render layout: 'new_homepage'
  end

  private

  def options_params
    params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
  end

end
