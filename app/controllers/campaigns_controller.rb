class CampaignsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :polls, :predict]
  before_action :set_current_member, only: [:predict, :list_reward]
  before_action :signed_user, only: [:index, :new]
  before_action :history_voted_viewed, only: [:list_reward]


  def predict
    @predict = @campaign.prediction(@current_member.id)
    puts "predict => #{@predict}"
  end

  def list_reward
    @rewards = @current_member.lucky_campaign.paginate(page: params[:next_cursor])
    @next_cursor = @rewards.next_page.nil? ? 0 : @rewards.next_page 
  end

  def polls
    @poll = @campaign.polls
    respond_to do |wants|
      wants.json { render json: @poll.to_json() }
    end
  end
  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Campaign.all
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
    @poll_campaign_new = Poll.where("campaign_id IS NULL OR campaign_id = 0 AND series = ? AND member_id = ?", false, current_member.id)
  end

  # GET /campaigns/1/edit
  def edit
    @poll_campaign_new = Poll.all
    @poll_campaigns = @campaign.polls

  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = current_member.campaigns.new(campaign_params)

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to @campaign, notice: 'Campaign was successfully created.' }
        format.json { render action: 'show', status: :created, location: @campaign }
      else
        format.html { render action: 'new' }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        @campaign.check_campaign_poll
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to campaigns_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(:name, :photo_campaign, :used, :limit, :begin_sample, :end_sample, :poll_ids, :expire)
    end
end
