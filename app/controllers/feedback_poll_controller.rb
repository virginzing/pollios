class FeedbackPollController < ApplicationController

  before_action :signed_user
  before_action :load_company

  def index
    @polls = Poll.joins(:branches).where("branch_polls.branch_id IN (?)", @company.branches.map(&:id))
  end

  def new

  end

  def reports

  end
end
