class PublicSurveys::FeedbacksController < ApplicationController

  before_action :only_public_survey
  before_action :set_poll_series, only: [:show, :edit, :update, :destroy]

  expose(:poll_series) { @poll_series.decorate }

  def index
    @feedbacks = Company::ListPollSeries.new(current_company).only_public_survey
  end

  def new
    @poll_series = PollSeries.new
    1.times do
      poll = @poll_series.polls.build
      2.times do
        poll.choices.build
      end
    end
  end

  def create
    PollSeries.transaction do
      @expire_date = poll_series_params["expire_date"].to_i

      @poll_series = current_member.poll_series.new(PollSeries::WebForm.new(current_member, poll_series_params).new_params)

      @poll_series.expire_date = set_expire_date
      @poll_series.campaign_id = poll_series_params[:campaign_id].presence || 0

      unless @poll_series.public
        @poll_series.in_group = true
        @poll_series.in_group_ids = "0"
        @poll_series.in_group_ids = poll_series_params[:group_id].select{|e| e if e.present? }.join(",")
      end

      type_series = poll_series_params["type_series"]

      if type_series == "1"
        @poll_series.same_choices = params[:same_choices].delete_if {|choice| choice == "" }
      end

      if @poll_series.save
        PollSeriesCompany.create_poll_series(@poll_series, current_company, :web)

        if @poll_series.in_group
          @poll_series.in_group_ids.split(",").each do |group_id|
            PollSeriesGroup.create!(poll_series_id: @poll_series.id, group_id: group_id.to_i, member_id: current_member.id)
          end
        end
        flash[:success] = "Successfully created feedback."
        redirect_to public_survey_feedbacks_path
      else
        flash[:error] = @poll_series.errors.full_messages
        render 'new'
      end
      Rails.cache.delete([current_member.id, 'my_questionnaire'])
    end
  end

  def show
    @array_list = []
    @poll_series.polls.each do |poll|
      @array_list << poll.choices.collect!{|e| e.answer.to_i * e.vote.to_f }.reduce(:+).round(2)
    end
    @qr = RQRCode::QRCode.new(GenerateQrcodeLink.new(@poll_series).get_redirect_link, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url
  end

  def edit

  end

  def update
    if poll_series_params[:remove_campaign].to_b
      @poll_series.campaign_id = 0
    end

    if @poll_series.update(poll_series_params)
      flash[:success] = "Successfully updated poll series."
      redirect_to public_survey_feedback_path(@poll_series)
    else
      render action: 'edit'
    end
  end

  def destroy
    NotifyLog.update_deleted_feedback(@poll_series)
    @poll_series.destroy
    flash[:success] = "Successfully destroyed feedback."
    redirect_to public_survey_feedbacks_path
  end

  private

  def set_expire_date
    if @expire_date == 0
      return Time.zone.now + 100.years
    else
      return Time.zone.now + @expire_date.days
    end
  end

  def set_poll_series
    @poll_series = PollSeries.cached_find(params[:id])
    raise ExceptionHandler::Forbidden if (@poll_series.member.id != current_member.id) || !@poll_series.public
  end

  def poll_series_params
    params.require(:poll_series).permit(:remove_campaign, :close_status, :allow_comment, :expire_within, :feedback, :campaign_id, :description, :member_id, :expire_date, :public, :tag_tokens, :type_poll, :type_series, :qr_only, :require_info, :group_id => [],:same_choices => [], polls_attributes: [:id, :member_id, :title, :photo_poll, :series, :type_poll, :_destroy, :choices_attributes => [:id, :poll_id, :answer, :_destroy]])
  end

end
