module Member::Private::RewardAction

  private

  def process_claim
    Member.transaction do
      if check_point_increment > 0
        current_point = @member.point
        member.update!(point: current_point + check_point_increment)
      end
      member_reward.update!(redeem: true, redeem_at: Time.zone.now, redeemer_id: member.id, reward_status: 1)
    end
    member_reward
  end

  def check_point_increment
    reward.options.present? ? reward.options['point'].to_i : 0 
  end

  def process_delete
    member_reward.destroy

    return
  end

end