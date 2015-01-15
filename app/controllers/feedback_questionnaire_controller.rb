class FeedbackQuestionnaireController < ApplicationController
  decorates_assigned :collections

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  before_action :set_questionnaire, only: [:show]

  def reports
    
  end

  def index
    @collections = CollectionPollSeries.where("company_id = ?", @company.id).decorate
  end

  def new
    @questionnaire = PollSeries.new

    2.times do
      poll = @questionnaire.polls.build
      2.times { poll.choices.build }
    end

    @branch_list = @company.branches 
  end

  def collection
    @collection = CollectionPollSeries.find(params[:id])
    @questionnaire_ids = @collection.collection_poll_series_branches.pluck(:poll_series_id)
    @questionnaires = PollSeries.joins(:branch)
                                .where("branch_poll_series.branch_id IN (?) AND poll_series.id IN (?)", @company.branches.map(&:id), @questionnaire_ids)
  
  end

  def edit_collection
    @collection = CollectionPollSeries.find(params[:id])
  end

  def create
    PollSeries.transaction do
      @success = true

      @collection = @company.collection_poll_series.create!(title: params[:poll_series][:description])

      params[:poll_series][:branch_list].select{|e| e if e.present? }.each do |branch_id|
        @expire_date = poll_series_params["expire_date"].to_i
        @poll_series = current_member.poll_series.new(poll_series_params)
        @poll_series.expire_date = set_expire_date
        @poll_series.campaign_id = poll_series_params[:campaign_id].presence || 0

        @poll_series.allow_comment = poll_series_params[:allow_comment] == "on" ? true : false
        @poll_series.qr_only = poll_series_params[:qr_only] == "on" ? true : false
        @poll_series.require_info = poll_series_params[:require_info] == "on" ? true : false

        if current_member.get_company.present?
          is_public = false
          @poll_series.in_group = false
          @poll_series.in_group_ids = "0"
        end

        type_series = poll_series_params["type_series"]

        if type_series == "1"
          @poll_series.same_choices = params[:same_choices].delete_if {|choice| choice == "" }
        end

        if @poll_series.save
          @collection.collection_poll_series_branches.create!(branch_id: branch_id, poll_series_id: @poll_series.id)
          BranchPollSeries.create!(poll_series_id: @poll_series.id, branch_id: branch_id.to_i)
          list_question = @poll_series.polls.map {|e| [e.order_poll, e.title] }.sort {|x,y| x[0] <=> y[0]}
          @collection.update(questions: list_question)  
        else
          @success = false
        end
      end


      if @success
        poll_series_ids =  @collection.collection_poll_series_branches.pluck(:poll_series_id)

        @collection.update(feedback_recurring_id: FeedbackRecurring.first.id, recurring_poll_series_set: poll_series_ids)

        flash[:success] = "Successfully created questionnaires."
        redirect_to feedback_questionnaires_path
      else
        flash[:error] = @poll_series.errors.full_messages
        render action: 'new'
      end
    end
    
  end

  def set_expire_date
    if @expire_date == 0
      return Time.zone.now + 100.years
    else
      return Time.zone.now + @expire_date.days
    end
  end

  def show
    
  end


  def destroy
  @collection_poll = CollectionPollSeries.find(params[:id])

    if @collection_poll
      
      @collection_poll.collection_poll_series_branches.each do |cp|
        cp.poll_series.destroy
      end

      @collection_poll.destroy
      flash[:success] = "Delete success"
      redirect_to feedback_questionnaires_path
    else
      flash[:error] = "Delete fail"
      render 'index'
    end
  end


  private

  def set_questionnaire
    @questionnaire = PollSeries.find(params[:id])
  end

  def poll_series_params
    params.require(:poll_series).permit(:allow_comment, :expire_within, :campaign_id, :description, :member_id, :expire_date, :tag_tokens, :type_series, :qr_only, :require_info, :feedback, :same_choices => [], polls_attributes: [:id, :member_id, :title, :photo_poll, :_destroy, :choices_attributes => [:id, :poll_id, :answer, :_destroy]])
  end

end
