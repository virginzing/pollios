module Member::Private::RewardActionGuard

  private 

  def can_claim?
    return [false, "This reward doesn't exist in your rewards"] if worng_reward
    return [false, 'This reward has expired.'] if expire_reward
    return [false, 'This campaign has be finished.'] if campaign_limit_exist
    return [false, 'You are already claimed this reward.'] if already_claim
    return [false, "You don't receive this reward."] if not_receive_reward
    [true, nil]
  end

  def worng_reward
    reward.member_id != member.id
  end

  def expire_reward
    campaign.rewards.first.reward_expire < Time.zone.now
  end

  def campaign_limit_exist
    campaign.used >= campaign.limit
  end

  def already_claim
    reward.redeem
  end

  def not_receive_reward
    reward.not_receive?
  end

end