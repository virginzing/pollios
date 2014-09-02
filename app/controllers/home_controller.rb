class HomeController < ApplicationController
  before_action :signed_user, only: [:dashboard]
  
  before_action :only_brand_or_company_account, only: [:dashboard]

  def dashboard
    @poll_latest_list = Poll.where(member_id: @current_member.id, series: false).order("created_at desc").limit(5)
    @poll_popular_list = Poll.where("member_id = #{@current_member.id} AND vote_all != 0 AND series = 'f'").order("vote_all desc").limit(5)
    if current_member.brand?
      @questionnaire = PollSeries.where(member_id: current_member.id).last
      render 'home/dashboard_brand'
    else
      render 'home/dashboard_company'
    end
  end
  
  def index
    render layout: 'homepage'
  end

end
