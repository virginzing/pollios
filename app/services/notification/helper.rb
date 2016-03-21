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

  def device_tokens_receive_notification(member)
    Apn::Device.where('receive_notification = true AND member_id IN (?)', member.id).map(&:token)
  end

  def notification_count(member_list, poll_id = 0)
    member_list.each do |member|
      member.increment!(:notification_count) if \
        member.received_notifies.where('custom_properties LIKE ? AND custom_properties LIKE ?' \
          , '%action: Create%', "%poll_id: #{poll_id}%") == []
      member.notification_count
    end
  end  

  def request_count(member_list)
    member_list.each do |member|
      member.increment!(:request_count)
      member.request_count
    end
  end

  def create_notification_for_push(device_token_list, custom_message, data = nil)
    device_token_list.each do |device_token|
      notification = Rpush::Apns::Notification.new
      notification.app = Rpush::Apns::App.first
      notification.device_token = device_token
      notification.alert = custom_message
      notification.badge = data[:notify]
      notification.sound = true
      notification.data = data
      notification.save!
    end
  end

  def create_notification_log(sender, recipient_list, message, data)
    recipient_list.each do |recipient|
      data.merge!(notify: recipient.notification_count)

      NotifyLog.create!(sender_id: sender.id, recipient_id: recipient.id, message: message, custom_properties: data)

      create_notification_for_push(device_tokens_receive_notification(recipient), message, data)
    end
  end

  def create_notification(sender, recipient_list, type, message, data)
    recipient_list = members_receive_notification(recipient_list, type)

    request_count(recipient_list) if type == 'request' || type == 'join_group'
    notification_count(recipient_list, data[:poll_id] || 0)
    
    create_notification_log(sender, recipient_list, truncate_message(message), data)
  end

end