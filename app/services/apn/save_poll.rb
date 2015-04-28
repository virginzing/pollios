class Apn::SavePoll

  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(params = {})
    @params = params
    @group_saved_poll = saved_poll
  end

  def recipient_ids
    @group_saved_poll.keys
  end

  # allow 170 byte for custom message
  def custom_message(receiver_id)
    number_of_saved_poll = @group_saved_poll[receiver_id] || 0
    message = "You have #{number_of_saved_poll} poll in save later."
    truncate_message(message)
  end

  private

  def saved_poll
    SavePollLater.select("member_id").group("save_poll_laters.member_id").size
  end
  
end
