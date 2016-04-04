class V1::Reward::ReceiveWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_reward_id)
    member_reward = MemberReward.cached_find(member_reward_id)
    Notification::Reward::Receive.new(member_reward)
  end

end