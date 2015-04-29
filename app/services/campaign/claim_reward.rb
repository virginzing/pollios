class Campaign::ClaimReward

  def initialize(member, reward)
    @member = member
    @reward = reward
  end

  def get_campaign
    @campaign ||= @reward.campaign
  end

  def check_point_increment
    get_campaign.reward_info.present? ? get_campaign.reward_info["point"].to_i : 0 
  end

  def claim
    begin
      Member.transaction do

        raise ExceptionHandler::UnprocessableEntity, "Reward has expired." if get_campaign.rewards.first.reward_expire < Time.zone.now

        raise ExceptionHandler::UnprocessableEntity, "Campaign has be finished." if get_campaign.used >= get_campaign.limit

        raise ExceptionHandler::UnprocessableEntity, "This reward had claimed already." if @reward.redeem

        raise ExceptionHandler::UnprocessableEntity, "Unlucky." unless @reward.luck

        if check_point_increment > 0
          current_point = @member.point
          @member.update!(point: current_point + check_point_increment)
          @reward.update!(redeem: true, redeem_at: Time.zone.now, redeemer_id: @member.id)
          true
        end
      end
      
    end
  end
  
end