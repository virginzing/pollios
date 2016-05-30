module Member::Private::RewardActionGuard

  private 

  def can_claim?
    return [false, "This reward doesn't exist in your rewards"] if worng_reward?
    return [false, 'This reward has expired.'] if expire_reward?
    return [false, 'This campaign has be finished.'] if reward_limit_exceed?
    return [false, 'You are already claimed this reward.'] if already_claim?
    return [false, "You don't receive this reward."] if not_receive_reward?
    [true, nil]
  end

  def can_delete?
    return [false, "This reward doesn't exist in your rewards"] if worng_reward?
    return [false, 'You are already claimed this reward.'] if already_claim?
    return [false, 'You have receive this reward.'] if receive_reward?
    [true, nil]
  end

  def worng_reward?
    member_reward.member_id != member.id
  end

  def expire_reward?
    reward.reward_expire < Time.zone.now
  end

  def reward_limit_exceed?
    reward.claimed >= reward.total
  end

  def already_claim?
    member_reward.redeem
  end

  def receive_reward?
    !member_reward.not_receive?
  end

  def not_receive_reward?
    member_reward.not_receive?
  end

end