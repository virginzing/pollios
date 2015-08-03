class CompanyCampaignsController < ApplicationController

  before_action :signed_user
  before_action :load_company
  before_action :check_using_service

  before_action :set_campaign, only: [:destroy, :edit, :update]

  def index
    @campaigns = @company.campaigns
  end

  def new
    @campaign = @company.campaigns.new
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

    @campaign = @company.campaigns.new(campaign_params)

    if @campaign.save
      flash[:success] = "Successfully created..."
      redirect_to company_campaigns_path
    else
      flash[:error] = "Fail"
      p @campaign.errors.messages
      redirect_to new_company_campaign_path
    end
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
      flash[:notice] = "Successfully updated..."
      redirect_to company_campaigns_path
    else
      flash[:error] = "Fail"
      redirect_to edit_company_campaign_path
    end
  end

  def destroy

  end



  private
  def set_campaign
    @campaign = Campaign.cached_find(params[:id])
    fail ExceptionHandler::Forbidden unless Company::ListCampaign.new(@company).access_campaign?(@campaign)
    @campaign
  end

  def campaign_params
    params.require(:campaign).permit(:unexpire, :announce_on, :system_campaign, :type_campaign, :member_id, :name, :description, :how_to_redeem, :limit, :expire, :photo_campaign, :end_sample, :begin_sample, :redeem_myself, :reward_expire, :reward_info => [:point, :first_signup], :rewards_attributes => [:id, :title, :detail, :reward_expire, :_destroy, :unexpire])
  end

end
