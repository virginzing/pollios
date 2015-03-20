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
      campaign.free_reward(member_id)
    end
  end

end