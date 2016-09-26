module Notification::NewHelper
  include Notification::LogHelper
  include Notification::PushHelper

  def create_log(member_list, type, data, message, sender = nil)
    recipient_list = recipient_list(member_list, sender)

    create_update_log(recipient_list, data, message, sender)
    create_request_log(recipient_list, data) if request_notification?(type)
  end

  def create_push(device_list_or_recipient_list, type, data = nil, message = nil)
    device_list = device_list_of(device_list_or_recipient_list)

    device_list.each do |device|
      Rpush::Apns::Notification.create!(notification_data_for(device, type, data, message))
    end
  end
end