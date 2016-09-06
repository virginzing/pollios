class Notification::Reward::Receive
  include Notification::Helper
  include SymbolHash

  attr_reader :member_reward, :campaign, :member

  def initialize(member_reward)
    @member_reward = member_reward
    @campaign = member_reward.campaign
    @member = campaign.member

    create(recipient_list, type, message, data)
  end

  def type
    nil
  end

  def recipient_list
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