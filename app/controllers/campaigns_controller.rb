class CampaignsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :polls, :predict]
  before_action :set_current_member, only: [:predict, :list_reward, :claim_reward, :delete_reward, :detail_reward]
  before_action :signed_user, only: [:index, :new, :show, :update, :destroy]
  before_action :history_voted_viewed, only: [:list_reward]

  before_action :set_reward, only: [:claim_reward]

  expose(:reward) { @reward }
  expose(:campaign) { @campaign }
  expose(:poll) { @poll }

  def claim_reward
    @claim = false
    init_reward = Campaign::ClaimReward.new(@current_member, @campaign_member)

    if init_reward.claim
      @claim = true
    end
  end

  def detail_reward
    @reward = CampaignMember.joins(:campaign, :member).cached_find(reward_params[:id])
  end

  def delete_reward
    @reward = CampaignMember.cached_find(reward_params[:id])
    @reward.destroy
    render status: @reward ? :created : :unprocessable_entity
  end

  def predict
    @predict = @campaign.prediction(@current_member.id)
    puts "predict => #{@predict}"
  end

  def list_reward
    @rewards = CampaignMember.without_deleted.list_reward(@current_member.id).paginate(page: params[:next_cursor])
    @next_cursor = @rewards.next_page.nil? ? 0 : @rewards.next_page
  end

  def poll_with_campaign
    @poll = Poll.find(params[:id])
    @campaign = @poll.campaign
    @list_reward = CampaignMember.joins(:poll).includes(:member).where(poll: @poll, campaign: @campaign)
  end

  def random_later_of_poll
    number_luck = params[:number_luck].to_i
    poll_id = params[:poll_id]
    @poll = Poll.find(params[:poll_id])
    @history_votes = HistoryVote.joins(:member, :poll).where('polls.id = ?', poll_id).sample(number_luck)
    @uniq_history_votes = @history_votes.uniq {|e| e.member_id }
    
    respond_to do |wants|
      wants.js
    end
  end

  def confirm_lucky_of_poll
    @poll = Poll.find(params[:poll_id])
    @campaign = @poll.campaign
    member_ids_receive_reward = params[:member_id].split().map(&:to_i)
    @confirm = @campaign.update_reward_random_of_poll(@poll, member_ids_receive_reward)

    respond_to do |wants|
      wants.js
    end
  end

  def load_poll
    @campaign = Campaign.find(params[:id])

    if params[:date_poll].present?
      @campaign_members = @campaign.campaign_members.where("poll_id = ? AND date(campaign_members.created_at + interval '7 hour') BETWEEN ? AND ?", params[:campaign_poll], params[:date_poll].to_date, params[:date_poll].to_date)
    else
      @campaign_members = @campaign.campaign_members.where("poll_id = ?", params[:campaign_poll])
    end

    @campaign_members = @campaign_members || []

    respond_to do |wants|
      wants.js
    end

  end

  def load_questionnaire
    @campaign = Campaign.find(params[:id])
    @questionnaire_ids = @campaign.poll_series.pluck(:id)

    @campaign_members = CampaignMember.where("campaign_id = #{@campaign.id} AND poll_series_id IN (?) AND date(campaign_members.created_at + interval '7 hour') BETWEEN ? AND ?", @questionnaire_ids, params[:date_questionnaire].to_date, params[:date_questionnaire].to_date)

    if @campaign_members.present?
      @campaign_members = @campaign_members
    else
      @campaign_members = []
    end

    respond_to do |wants|
      wants.js
    end
  end

  def load_questionnaire_feedback
    @campaign = Campaign.find(params[:id])

    @collection = CollectionPollSeries.find(params[:campaign_questionnaire])
    @questionnaire_ids = @collection.collection_poll_series_branches.pluck(:poll_series_id)

    @campaign_members = CampaignMember.where("campaign_id = #{@campaign.id} AND poll_series_id IN (?) AND date(campaign_members.created_at + interval '7 hour') BETWEEN ? AND ?", @questionnaire_ids, params[:date_questionnaire].to_date, params[:date_questionnaire].to_date)

    if @campaign_members.present?
      @campaign_members = @campaign_members
    else
      @campaign_members = []
    end

    respond_to do |wants|
      wants.js
    end
  end

  def random_later
    number_luck = params[:number_luck].to_i

    @collection = CollectionPollSeries.find(params[:collection_id])

    @questionnaire_ids = @collection.collection_poll_series_branches.pluck(:poll_series_id)

    @history_votes = HistoryVote.joins(:member).where("poll_series_id IN (?)", @questionnaire_ids).sample(number_luck)

    puts "history_votes begin => #{@history_votes.map(&:member_id)}"

    @uniq_history_votes = @history_votes.uniq{|e| e.member_id }

    puts "history_votes => #{@uniq_history_votes}"
    respond_to do |wants|
      wants.js
    end
  end

  def confirm_lucky
    
    if params[:member_id].present?
      member_id = params[:member_id].split(" ")

      
    end

    respond_to do |wants|
      wants.js
    end
  end


  def check_redeem
    
    ## don't forget clear cache reward ##
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
    @campaigns = current_member.campaigns.includes(:polls)
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    @poll_series = PollSeries.find_by(id: params[:psId]) if params[:psId]
    @poll_series_id = @poll_series.id if @poll_series.present?
    
    @list_poll = Company::ListPoll.new(current_member.get_company).list_polls.where("campaign_id = ?", @campaign.id)
    @list_questionnaire = Company::ListPollSeries.new(current_member.get_company).list_poll_series.where("campaign_id = ?", @campaign.id)
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
    @poll_campaign_new = Poll.where("campaign_id IS NULL OR campaign_id = 0 AND series = ? AND member_id = ?", false, current_member.id)
    # @poll_campaigns = @campaign.poll
    # @campaign.polls = Poll.new
  end

  # GET /campaigns/1/edit
  def edit
    @poll_campaign_new = Poll.all
    @poll_campaigns = @campaign.polls
    # @poll_campaigns = PollOfCampaignSerializer.new(@campaign.poll).to_json()
    # puts "#{@poll_campaigns}"
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = current_member.campaigns.new(campaign_params)

    respond_to do |format|
      if @campaign.save
        @campaign.set_campaign_poll
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
        # Poll.find(campaign_params[:poll_id] || params[:id]).update_attributes!(campaign_id: @campaign.id )
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
    flash[:success] = "Destroy completely"
    respond_to do |format|
      if params[:type] == "feedback"
        format.html { redirect_to feedback_campaigns_path }
      else
        format.html { redirect_to company_campaigns_path }
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def reward_params
      params.permit(:member_id, :id)
    end

    def set_reward
      @campaign_member = CampaignMember.find_by(id: params[:reward_id], member_id: params[:member_id], ref_no: params[:ref_no])
      raise ExceptionHandler::NotFound, "Reward not found" unless @campaign_member.present?
      @campaign_member  
    end

    def redeem_code_params
      params.permit(:serial_code, :member_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(:name, :photo_campaign, :used, :limit, :begin_sample, :end_sample, :poll_ids, :expire, :poll_id, :description, :how_to_redeem)
    end
end
