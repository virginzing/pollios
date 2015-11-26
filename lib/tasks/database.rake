namespace :database do

  desc '[use only once] migrate old (incorrect) campaign -> reward'
  task copy_reward_data: :environment do
    Campaign.find_each do |campaign|
      reward = campaign.rewards.first
      reward.update_attribute(:total, campaign.limit)
      reward.update_attribute(:claimed, campaign.used)
      reward.update_attribute(:odds, campaign.end_sample)
      reward.update_attribute(:expire_at, reward.reward_expire)
      reward.update_attribute(:redeem_instruction, campaign.how_to_redeem)
      reward.update_attribute(:self_redeem, campaign.redeem_myself)
      reward.update_attribute(:options, campaign.reward_info)
    end
  end

  desc '[use only once] populate reward_id in campaign_members using campaign_id'
  task copy_reward_id_from_campaign_id: :environment do
    CampaignMember.find_each do |campaign_member|
      campaign_member.update_attribute(:reward_id, campaign_member.campaign_id)
    end
  end
end