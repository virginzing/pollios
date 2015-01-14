class FeedbackReportsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  # before_action :set_questionnaire, only: [:show , :destroy]

  def collection
    @collection = CollectionPollSeries.find(params[:id])
    @questionnaire_ids = @collection.collection_poll_series_branches.pluck(:poll_series_id)

    @questionnaires ||= PollSeries.filter_by(params[:startdate], params[:finishdate], params[:filter_by]).includes(:polls).joins(:branch)
                                .where("branch_poll_series.branch_id IN (?) AND poll_series.id IN (?)", @company.branches.map(&:id), @questionnaire_ids)
                               
    @branches = Branch.joins(:branch_poll_series => :poll_series)
                      .select("branches.*, count(branch_poll_series.poll_series_id) as questionnaire_count, sum(poll_series.vote_all) as questionnaire_vote_all")
                      .where("branch_poll_series.poll_series_id IN (?)", @questionnaires.map(&:id))
                      .filter_by(params[:startdate], params[:finishdate], params[:filter_by]).group('branches.id').order("branches.name asc").uniq

  end

  def each_branch
    @branch = Branch.find(params[:branch_id])
    @collection = CollectionPollSeries.find(params[:id])

    @questionnaire_ids = @collection.collection_poll_series_branches.pluck(:poll_series_id)
    @questionnaires ||= PollSeries.filter_by(params[:startdate], params[:finishdate], params[:filter_by]).includes(:polls).joins(:branch)
                                .where("branch_poll_series.branch_id = ? AND poll_series.id IN (?)", @branch.id, @questionnaire_ids)
  end

  def polls
    
  end


end
