class Apn::NotifyExpireSubscription
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper


  def custom_message
    message = "Your subscription has expired now"
    truncate_message(message)
  end
  
end