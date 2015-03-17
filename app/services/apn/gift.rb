class Apn::Gift
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(receive, message)
    @member = receive
    @message = message || "You got reward"
  end

  def recipient_ids
    @member.id
  end

  # allow 170 byte for custom message
  def custom_message
    truncate_message(@message)
  end
  
  
end