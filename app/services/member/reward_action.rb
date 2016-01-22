class Member::RewardAction

  include Member::Private::RewardActionGuard
  include Member::Private::RewardAction

  attr_reader :member, :reward, :campaign

  def initialize(member, reward)
    @member = member
    @reward = reward
    @campaign = reward.campaign
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