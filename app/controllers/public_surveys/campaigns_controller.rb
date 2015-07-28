class PublicSurveys::CampaignsController < ApplicationController

  before_action :only_public_survey

  before_action :set_campaign, only: [:destroy, :edit, :update, :show]

  def index
    @campaigns = current_company.campaigns
  end

  def new
    @campaign = current_company.campaigns.new
    1.times do
      @campaign.rewards.build
    end
  end

  def create
    set_unexpire = Time.zone.now + 100.years

    if campaign_params[:unexpire].to_b
      params[:campaign][:expire] = set_unexpire
    end

    if campaign_params["rewards_attributes"]["0"]["unexpire"].to_b
      params[:campaign][:rewards_attributes]["0"][:reward_expire] = set_unexpire
    end

    @campaign = current_company.campaigns.new(campaign_params)

    if @campaign.save
      flash[:success] = "Successfully created campaign."
      redirect_to public_survey_campaigns_path
    else
      flash[:error] = "Fail"
      p @campaign.errors.messages
      redirect_to new_public_survey_campaign_path
    end
  end

  def show
    @poll_series = PollSeries.find_by(id: params[:psId]) if params[:psId]
    @poll_series_id = @poll_series.id if @poll_series.present?

    @list_poll = Company::ListPoll.new(current_company).list_polls.where("campaign_id = ?", @campaign.id)
    @list_questionnaire = Company::ListPollSeries.new(current_company).list_poll_series.where("campaign_id = ?", @campaign.id)
  end

  def edit
    @reward_unexpired = @campaign.rewards.first.unexpired?
  end

  def update
    set_unexpire = Time.zone.now + 100.years

    if campaign_params[:unexpire].to_b
      params[:campaign][:expire] = set_unexpire
    end

    if campaign_params["rewards_attributes"]["0"]["unexpire"].to_b
      params[:campaign][:rewards_attributes]["0"][:reward_expire] = set_unexpire
    end

    if @campaign.update(campaign_params)
      flash[:success] = "Successfully updated campaign."
      redirect_to public_survey_campaigns_path
    else
      flash[:error] = "Fail"
      redirect_to edit_public_survey_campaign_path(@campaign)
    end
  end

  def destroy
    @campaign.destroy
    flash[:success] = "Successfully removed campaign."
    redirect_to public_survey_campaigns_path
  end

  private

  def set_campaign
    @campaign = Campaign.cached_find(params[:id])
    fail ExceptionHandler::Forbidden unless Company::ListCampaign.new(current_company).access_campaign?(@campaign)
    @campaign
  end

  def campaign_params
    params.require(:campaign).permit(:unexpire, :announce_on, :system_campaign, :type_campaign, :member_id, :name, :description, :how_to_redeem, :limit, :expire, :photo_campaign, :end_sample, :begin_sample, :redeem_myself, :reward_expire, :reward_info => [:point], :rewards_attributes => [:id, :title, :detail, :reward_expire, :_destroy, :unexpire])
  end

end
