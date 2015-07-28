class PublicSurveys::FlagsController < ApplicationController

  before_action :only_public_survey

  def index
    company_groups = Company::ListGroup.new(current_company).all
    @report_polls = Company::CompanyReportPoll.new(company_groups, current_company).get_report_poll_in_company
  end

end
