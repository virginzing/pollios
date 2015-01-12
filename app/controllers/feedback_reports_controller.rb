class FeedbackReportsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  # before_action :set_questionnaire, only: [:show , :destroy]

  def collection
    @collection = CollectionPoll.find(params[:id])
    @questionnaire_ids = Groupping.where("collection_poll_id = ?", params[:id]).pluck(:groupable_id)
    @questionnaires ||= PollSeries.filter_by(params[:startdate], params[:finishdate], params[:filter_by]).includes(:polls).joins(:branch)
                                .where("branch_poll_series.branch_id IN (?) AND poll_series.id IN (?)", @company.branches.map(&:id), @questionnaire_ids)
                               
    puts "map => #{@questionnaires.map(&:id)}"
    @branches = Branch.joins(:branch_poll_series => :poll_series)
                      .select("branches.*, count(branch_poll_series.poll_series_id) as questionnaire_count, sum(poll_series.vote_all) as questionnaire_vote_all")
                      .where("branch_poll_series.poll_series_id IN (?)", @questionnaires.map(&:id))
                      .filter_by(params[:startdate], params[:finishdate], params[:filter_by]).group('branches.id').order("branches.name asc").uniq

  end

  def polls
    
  end


end
