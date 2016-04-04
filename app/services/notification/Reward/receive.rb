class Notification::Reward::Receive
  include Notification::Helper
  include SymbolHash

  attr_reader :member_reward, :campaign, :member

  def initialize(member_reward)
    @member_reward = member_reward
    @campaign = member_reward.campaign
    @member = campaign.member

    create_notification(recipient_list, type, message, data)
  end

  def type
    nil
  end

  def recipient_list
    [member_reward.member]
  end

  def message
    "You got reward from campaign: \"#{campaign.name}\""
  end

  def data
    @data ||= {
      type: TYPE[:reward],
      redeemable_info: { redeem_id: member_reward.id },
      worker: WORKER[:receive_reward]
    }
  end

end