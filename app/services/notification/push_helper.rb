module Notification::PushHelper

  private

  def device_list(recipient_list)
    recipient_list.map(&:apn_devices).flatten
  end

  def push_data(device, type, data, message)
    recipient = device.member
    notification_data = notification_data(device.token, data)

    return notification_data unless alert?(device, type)

    notification_data.merge(alert_data(recipient, message))
  end

  def alert?(device, type)
    return true if type == :always
    return false if type == :never

    receive_notification?(device, type)
  end

  def receive_notification?(device, type)
    recipient_receive_notification?(device.member, type) && device_receive_notification?(device)
  end

  def recipient_receive_notification?(recipient, type)
    recipient.notification[type].to_b
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

    limit_message += "...\"" if limit_message != message

    limit_message + '.'
  end
end