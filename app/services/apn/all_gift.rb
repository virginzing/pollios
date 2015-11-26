class Apn::AllGift
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(gift_log)
    @gift_log = gift_log
  end

  def recipient_ids
    @gift_log.list_member
  end

  # allow 170 byte for custom message
  def custom_message
    message = "You got reward \"#{@gift_log.message}\""
    truncate_message(message)
  end

  def campaign
    @campaign ||= @gift_log.campaign
  end

  def send
    recipient_ids.each do |member_id|
      reward = campaign.free_reward(member_id, @gift_log)
    end
  end

  def hash_member_ids_with_reward
    MemberReward.joins(:member, :campaign).with_reward_status(:receive).where(gift_log_id: @gift_log.id).inject ({}) do |hash, val| 
      hash[val.member_id] = val.id
      hash
    end
  end  

end