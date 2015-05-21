class ApnNotReceiveRandomRewardPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(sender, poll, list_member, message = nil)
    @sender = sender
    @poll = poll
    @message = message
    @list_member = list_member
  end

  def campaign
    @poll.campaign
  end

  def recipient_ids
    @list_member
  end

  def custom_message
    message = @message || "#{@sender.get_name} announce reward. Sorry! You don't get reward"
    truncate_message(message)
  end 

  def list_hash_reward_with_member_ids
    CampaignMember.joins(:member).with_reward_status(:not_receive).where(poll: @poll).inject({}) {|h,v| h[v.member_id] = v.id; h }
  end
  
  
end