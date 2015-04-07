class Apn::NearlyExpireSubscription
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper


  def custom_message
    message = "Your subscribe remain about 3 days"
    truncate_message(message)
  end
     
end