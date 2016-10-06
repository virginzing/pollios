module Notification::LogHelper

  private

  def create_log(recipient_list, data, message, sender = nil)
    create_update_log(recipient_list, data, message, sender)
    create_request_log(recipient_list, data) if request_notification?
  end
  

  def create_update_log(recipient_list, data, message, sender)
    sender_id = sender.id if sender.present?
    message = log_message(message)

    recipient_list.each do |recipient|
      increase_notification_count_for(recipient)
      data_with_badge_data = data.merge(badge_data(recipient))

      create_update_log_for(recipient, sender_id, data_with_badge_data, message)
    end
  end

  def create_request_log(recipient_list, data)
    recipient_list.each do |recipient|
      increase_request_count_for(recipient)
      create_recent_request(recipient, data)
    end
  end

  def log_message(message)
    message + '.'
  end

  def increase_notification_count_for(recipient)
    recipient.increment!(:notification_count)
  end

  def badge_data(recipient)
    { notify: recipient.notification_count }
  end

  def create_update_log_for(recipient, sender_id, data, message)
    NotifyLog.create!(recipient_id: recipient.id, sender_id: sender_id, custom_properties: data, message: message)
  end

  def request_notification?
    alert_type == 'request'
  end

  def increase_request_count_for(recipient)
    recipient.increment!(:request_count)
  end

  def create_recent_request(recipient, data)
    return create_request_log_recent_friends(recipient, data) if accept_friend_request?(data)

    create_request_log_recent_group(recipient, data) if approve_group_request?(data)
  end

  def accept_friend_request?(data)
    data[:action] == 'BecomeFriend'
  end

  def approve_group_request?(data)
    data[:action] == 'Join'
  end

  def create_request_log_recent_friends(recipient, data)
    friends = Member.cached_find(data[:member_id])

    create_recent_request_for(recipient, friends)
    clear_cached_recent_friends_for(recipient)
  end

  def create_request_log_recent_group(recipient, data)
    group = Group.cached_find(data[:group_id])

    create_recent_request_for(recipient, group)
    clear_cached_recent_group_for(recipient)
  end

  def create_recent_request_for(recipient, object)
    MemberRecentRequest.create!(member_id: recipient.id, recent: object)
  end

  def clear_cached_recent_friends_for(recipient)
    FlushCached::Member.new(recipient).clear_list_recent_friends
  end

  def clear_cached_recent_group_for(recipient)
    FlushCached::Member.new(recipient).clear_list_recent_groups
  end
end