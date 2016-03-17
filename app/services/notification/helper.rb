module Notification::Helper

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

  def members_receive_notification(member_list, type)
    member_list.select { |member| member if member.notification[type].to_b }.uniq
  end

  def device_tokens_receive_notification(member_list)
    Apn::Device.where('receive_notification = true AND member_id IN (?)', member_list.map(&:id)).map(&:token)
  end

  def create_notification_for_push(device_token_list, custom_message, data)
    device_token_list.each do |device_token|
      notification = Rpush::Apns::Notification.new
      notification.app = Rpush::Apns::App.first
      notification.device_token = device_token
      notification.alert = custom_message
      notification.badge = notification_count
      notification.sound = true
      notification.data = data
      notification.save!
    end
  end

  def create_notification_log(sender, recipients, message, data)
    recipients.each do |recipient|
      NotifyLog.create!(sender_id: sender.id, recipient_id: recipient.id, message: message, custom_properties: data)
    end
  end

  def create_notification(sender, recipients, type, message, data)
    recipients = members_receive_notification(recipients, type)

    create_notification_for_push(device_tokens_receive_notification(recipients), truncate_message(message), data)
    create_notification_log(sender, recipients, truncate_message(message), data)
  end

end