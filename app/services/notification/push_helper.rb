module Notification::PushHelper

  private

  def device_list(recipient_list)
    recipient_list.map(&:apn_devices).flatten
  end

  def push_data(device, type, data, message)
    recipient = device.member
    notification_data = notification_data(device.token, data)

    return notification_data if push_data_only?(recipient, device, type)

    notification_data.merge(alert_data(recipient, message))
  end

  def push_data_only?(recipient, device, type)
    remove_action?(type) || turn_off_notification?(recipient, device, type)
  end

  def remove_action?(type)
    type == 'remove'
  end

  def turn_off_notification?(recipient, device, type)
    recipient_turn_off_notification?(recipient, type) || device_turn_off_notification?(device)
  end

  def recipient_turn_off_notification?(recipient, type)
    !recipient.notification[type].to_b
  end

  def device_turn_off_notification?(device)
    !device.receive_notification
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