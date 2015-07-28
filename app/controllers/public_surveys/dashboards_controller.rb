class PublicSurveys::DashboardsController < ApplicationController

  before_action :only_public_survey

  def index
    @poll_latest_in_public = Company::PollPublic.new(current_company).get_list_public_poll
  end

end

