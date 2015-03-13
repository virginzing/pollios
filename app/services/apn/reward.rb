class Apn::Reward
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(reward)
    @reward = reward
  end

  def recipient_ids
    @reward.member_id
  end

  def campaign
    @campaign ||= @reward.campaign
  end

  # allow 170 byte for custom message
  def custom_message
    message = "You got reward from campaign: \"#{campaign.name}\""
    truncate_message(message)
  end
  
end