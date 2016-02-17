module Campaign::Private::RewardPredictionGuard

  private

  def can_predict?
    return [false, 'This campaign was expire.'] if campaign_expire
    return [false, 'This campaign was limit.'] if campaign_limit_exist
    return [false, 'You used to get this reward of this campaign.'] if used_to_get_reward
    [true, nil]
  end

  def campaign_expire
    campaign.expire < Time.now
  end

  def campaign_limit_exist
    campaign.limit <= campaign.used
  end

  def used_to_get_reward
    campaign.member_rewards.find_by(member_id: member.id).present?
  end

end