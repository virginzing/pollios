class Campaign::ClaimReward

  def initialize(member, reward)
    @member = member
    @reward = reward
  end

  def get_campaign
    @campaign ||= @reward.campaign
  end

  def check_point_increment
    get_campaign.reward_info.present? ? get_campaign.reward_info['point'].to_i : 0 
  end

  def can_claim?
    return false, 'Reward has expired.' if get_campaign.rewards.first.reward_expire < Time.zone.now
    return false, 'Campaign has be finished.' if get_campaign.used >= get_campaign.limit
    return false, 'This reward had claimed already.' if @reward.redeem
    return false, "Don't receive reward." if @reward.not_receive?
    [true, '']
  end

  def claim
    can_claim, message = can_claim?
    fail ExceptionHandler::UnprocessableEntity, message unless can_claim

    Member.transaction do
      if check_point_increment > 0
        current_point = @member.point
        @member.update!(point: current_point + check_point_increment)
        @reward.update!(redeem: true, redeem_at: Time.zone.now, redeemer_id: @member.id)
      end
    end
    true
  end
  
end