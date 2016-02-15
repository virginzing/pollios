class Member::RewardAction

  include Member::Private::RewardActionGuard
  include Member::Private::RewardAction

  attr_reader :member, :member_reward, :reward

  def initialize(member, member_reward)
    @member = member
    @member_reward = member_reward
    @reward = member_reward.reward
  end

  def claim
    can_claim, message = can_claim?
    fail ExceptionHandler::UnprocessableEntity, message unless can_claim

    process_claim
  end

  def delete
    can_delete, message = can_delete?
    fail ExceptionHandler::UnprocessableEntity, message unless can_delete

    process_delete
  end

end