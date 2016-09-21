class Notification::Reward::Receive
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :member_reward, :campaign

  def initialize(member_reward)
    @member_reward = member_reward
    @campaign = member_reward.campaign
    @sender = campaign.member

    create(member_list, type, message, data)
  end

  def type
    nil
  end

  def member_list
    [member_reward.member]
  end

  def message
    return "You got reward from campaign \"#{campaign.name}\"" if member_reward.reward_status.receive?
    "Sorry! You don't get reward from poll \"#{member_reward.poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:reward],
      redeemable_info: { 
        redeem_id: member_reward.id,
        reward_status: member_reward.reward_status
      },
      worker: WORKER[:receive_reward]
    }
  end

end