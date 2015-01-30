class FeedbackCampaignsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  before_action :check_using_service

  before_action :set_campaign, only: [:destroy, :edit, :update, :show]

  def index
    @campaigns = @company.campaigns
  end

  def new
    @campaign = @company.campaigns.new
  end

  def show
    @list_poll = Poll.unscoped.where(campaign_id: @campaign.id, series: false)
    @list_collection = CollectionPollSeries.where("company_id = ? AND campaign_id != 0", @company.id)
  end

  def create
    @campaign = @company.campaigns.new(campaign_params)

    if @campaign.save
      flash[:success] = "Successfully created..."
      redirect_to feedback_campaigns_path
    else
      flash[:error] = "Fail"
      redirect_to new_feedback_campaign_path
    end
  end

  def edit
    
  end

  def update
    if @campaign.update(campaign_params)
      flash[:success] = "Successfully updated..."
      redirect_to feedback_campaigns_path
    else
      flash[:error] = "Fail"
      redirect_to edit_feedback_campaign_path
    end
  end

  def destroy
    
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:type_campaign, :member_id, :name, :description, :how_to_redeem, :limit, :expire, :photo_campaign, :end_sample, :begin_sample)
  end
  
end
