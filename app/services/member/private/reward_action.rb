module Member::Private::RewardAction

  private

  def process_claim
    Member.transaction do
      if check_point_increment > 0
        current_point = @member.point
        member.update!(point: current_point + check_point_increment)
        reward.update!(redeem: true, redeem_at: Time.zone.now, redeemer_id: member.id, reward_status: 1)
      end
    end
    reward
  end

  def check_point_increment
    campaign.reward_info.present? ? campaign.reward_info['point'].to_i : 0 
  end

  def process_delete
    reward.destroy

    return
  end

end