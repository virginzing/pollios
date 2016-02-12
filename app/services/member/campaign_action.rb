class Member::CampaignAction

  attr_reader :member, :campaign_params

  def initialize(member)
    @member = member
  end

  def create(params)
    @campaign_params = params
    process_create_campaign
  end

  def process_create_campaign
    campaign = Campaign.new(new_campaign_params_hash)
    campaign.save!

    add_rewards(campaign)

    campaign
  end

  def new_campaign_params_hash
    {
      member_id: member.id,
      company_id: member.company.present? ? member.company.id : nil,
      name: campaign_params[:name],
      photo_campaign: campaign_params[:photo],
      end_sample: campaign_params[:end_sample] || 1,
      announce_on: campaign_params[:announce_on],
      type_campaign: campaign_params[:announce_on].present? ? 'random_later' : 'random_immediately',
      reward_expire: campaign_params[:reward_expire] || Time.now + 100.year,
      expire: campaign_params[:expire_at] || Time.now + 100.year
    }
  end

  def add_rewards(campaign)
    campaign.rewards << new_reward_list_for_campaign(campaign)
  end

  def new_reward_list_params_hash(campaign)
    new_reward_list_params_hash = []

    campaign_params[:rewards].each do |reward_parms|

      new_params_reward_hash = {
        campaign_id: campaign.id,
        title: reward_parms[:title],
        detail: reward_parms[:detail],
        total: reward_parms[:total],
        odds: reward_parms[:odds],
        redeem_instruction: reward_parms[:redeem_instruction],
        self_redeem: reward_parms[:self_redeem],
        reward_expire: reward_parms[:reward_expire] || Time.now + 100.year,
        expire_at: reward_parms[:expire_at] || Time.now + 100.year,
        claimed: 0
      }
      new_reward_list_params_hash << new_params_reward_hash
    end
    new_reward_list_params_hash
  end 

  def new_reward_list_for_campaign(campaign)
    new_reward_list_for_campaign = []

    new_reward_list_params_hash(campaign).each do |reward_parms|
      reward_for_campaign = Reward.create!(reward_parms)

      new_reward_list_for_campaign << reward_for_campaign
    end
    new_reward_list_for_campaign
  end

end