module Notification::PushHelper

  private

  def create_push(recipient_list, data, message = nil)
    device_list = device_list(recipient_list)

    device_list.each do |device|
      Rpush::Apns::Notification.create!(push_data(device, data, message))
    end
  end


  def device_list(recipient_list)
    recipient_list.map(&:apn_devices).flatten
  end

  def push_data(device, data, message)
    recipient = device.member
    notification_data = notification_data(device.token, data)

    return notification_data unless alert?(device)

    notification_data.merge(alert_data(recipient, message))
  end

  def alert?(device)
    return true if alert_type == :always
    return false if alert_type == :never

    receive_notification?(device)
  end

  def receive_notification?(device)
    recipient_receive_notification?(device.member) && device_receive_notification?(device)
  end

  def recipient_receive_notification?(recipient)
    recipient.notification[alert_type].to_b
  end

  def device_receive_notification?(device)
    device.receive_notification
  end

  def notification_data(device_token, data)
    {
      app: Rpush::Apns::App.find_by(name: 'Pollios'),
      device_token: device_token,
      data: data,
      sound: false,
      content_available: true 
    }
  end

  def alert_data(recipient, message)
    {
      badge: recipient.notification_count,
      alert: truncate_message(message),
      sound: true,
      content_available: false
    }
  end

  def truncate_message(message, limit_message_byte = 90, decrement_byte = 8)
    message = message.sub(/\n\n/, ' ')

    limit_message = nil

    loop do
      limit_message_byte -= decrement_byte
      limit_message = message.mb_chars.limit(limit_message_byte).to_s

      break unless limit_message.to_json.bytesize > 92
    end

    limit_message += '..."' if limit_message != message

    limit_message + '.'
  end
end