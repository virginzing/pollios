class CompanyCampaignsController < ApplicationController
  
  skip_before_action :verify_authenticity_token
  before_action :signed_user
  before_action :load_company
  before_action :check_using_service

  before_action :set_campaign, only: [:destroy, :edit, :update]

  def index
    @campaigns = @company.campaigns
  end

  def new
    @campaign = @company.campaigns.new
  end

  def create
    @campaign = @company.campaigns.new(campaign_params)

    if @campaign.save
      flash[:notice] = "Successfully created..."
      redirect_to company_campaigns_path
    else
      flash[:error] = "Fail"
      redirect_to new_company_campaign_path
    end
  end

  def edit
    
  end

  def update
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
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:type_campaign, :member_id, :name, :description, :how_to_redeem, :limit, :expire, :photo_campaign, :end_sample, :begin_sample)
  end

end
