module Notification::Helper

  def create(recipient_list, type, message, data, options = { log: true, push: true })
    recipient_list = recipients_receive_notification(recipient_list, type)
    message = truncate_message(message)

    create_request(recipient_list, type, data) if request_notification?(type)
    create_notification(recipient_list, message, data, options[:log], options[:push])
  end

  def recipients_receive_notification(recipient_list, type = nil)
    return recipient_list if type.nil?
    recipient_list.select { |recipient| recipient if recipient.notification[type].to_b }.uniq - [sender]
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

  def request_notification?(type)
    type == 'request'
  end

  def create_request(recipient_list, type, data)
    recipient_list.each do |recipient|
      increase_request_count(recipient)
      create_recent_request(recipient, data)
    end
  end

  def increase_request_count(recipient)
    recipient.increment!(:request_count)
    recipient.request_count
  end

  def create_recent_request(recipient, data)
    add_recent_friends_to_request(recipient, data) if accept_friend_request?(data)
    add_recent_group_to_request(recipient, data) if approve_group_request?(data)
  end

  def add_recent_friends_to_request(recipient, data)
    friends = Member.cached_find(data[:member_id])

    create_recipient_recent_request(recipient, friends)

    FlushCached::Member.new(recipient).clear_list_recent_friends
  end

  def accept_friend_request?(data)
    data[:action] == 'BecomeFriend'
  end

  def add_recent_group_to_request(recipient, data)
    group = Group.cached_find(data[:group_id])

    create_recipient_recent_request(recipient, group)

    FlushCached::Member.new(recipient).clear_list_recent_groups
  end

  def approve_group_request?(data)
    data[:worker] == 'ApproveRequestGroup'
  end

  def create_recipient_recent_request(recipient, object)
    MemberRecentRequest.create!(member_id: recipient.id, recent: object)
  end

  def create_notification(recipient_list, message, data, log, push)
    increase_notification_count(recipient_list, data[:action], data[:poll_id] || 0)

    create_notification_log(recipient_list, message, data) if log
    create_notification_for_push(devices_receive_notification(recipient_list), message, data) if push
  end

  def devices_receive_notification(recipient_list)
    Apn::Device.where('receive_notification = true AND member_id IN (?)', recipient_list.map(&:id)) 
  end

  def increase_notification_count(recipient_list, action, poll_id = 0)
    recipient_list.each do |recipient|
      recipient.increment!(:notification_count) if recipient_never_received_notification_from_create_poll_id(action, recipient, poll_id)
      recipient.notification_count
    end
  end

  def recipient_never_received_notification_from_create_poll_id(action, recipient, poll_id)
    action != 'Create' || recipient.received_notifies.where('custom_properties LIKE ? AND custom_properties LIKE ?' \
      , "%action: Create%", "%poll_id: #{poll_id}%").empty?
  end

  def create_notification_log(recipient_list, message, data)
    sender_id = (sender.present? ? sender.id : nil)

    recipient_list.each do |recipient|
      data.merge!(notify: recipient.notification_count)

      NotifyLog.create!(sender_id: sender_id, recipient_id: recipient.id, message: message, custom_properties: data)
    end
  end

  def create_notification_for_push(device_list, custom_message, data = nil)
    device_list.each do |device|
      notification = Rpush::Apns::Notification.new
      notification.app = Rpush::Apns::App.first
      notification.device_token = device.token
      notification.alert = custom_message
      notification.badge = device.member.notification_count
      notification.sound = true
      notification.data = data
      notification.save!
    end
  end
end