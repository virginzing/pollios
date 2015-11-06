namespace :database do

  desc "use only once to migrate old (incorrect) campaign -> reward"
  task :copy_reward_data => :environment do
    Campaign.find_each do |campaign|
      reward = campaign.rewards.first
      reward.update_attribute(:total, campaign.limit)
      reward.update_attribute(:claimed, campaign.used)
      reward.update_attribute(:odds, campaign.end_sample)
      reward.update_attribute(:expire_at, campaign.reward_expire)
      reward.update_attribute(:redeem_instruction, campaign.how_to_redeem)
      reward.update_attribute(:self_redeem, campaign.redeem_myself)
      reward.update_attribute(:options, campaign.reward_info)
    end
  end
end