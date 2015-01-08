class FeedbackReportsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  # before_action :set_questionnaire, only: [:show , :destroy]

  def collection
    @collection = CollectionPoll.find(params[:id])
    @questionnaire_ids = Groupping.where("collection_poll_id = ?", params[:id]).pluck(:groupable_id)
    @questionnaires ||= PollSeries.includes(:polls).joins(:branch)
                                .where("branch_poll_series.branch_id IN (?) AND poll_series.id IN (?)", @company.branches.map(&:id), @questionnaire_ids)

    @questionnaire = @questionnaires.first

    @branches = Branch.joins(:branch_poll_series).where("branch_poll_series.poll_series_id IN (?)", @questionnaire_ids)
  end

  def polls
    
  end


end
