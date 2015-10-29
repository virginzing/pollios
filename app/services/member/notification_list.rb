class Member::NotificationList

  def initialize(member, options = {})
    @member = member
    if options[:next_notifications]
      @next_notifications = options[:next_notifications]
    else
      @next_notifications = 0
    end

    if options[:clear_new_count]
      reset_new_notification_count
    end
  end

  def notifications_at_current_page
    notifications
  end

  def notifications_count
    @member.received_notifies.without_deleted.count
  end

  def next_notifications
    notifications.last.nil? ? 0 : notifications.last.id
  end

  def reset_new_notification_count
    @member.notification_count = 0
    @member.save!
  end

  private

  def notifications
    @notifications ||= @member.received_notifies.without_deleted.order("created_at DESC").order("id DESC").limit(ENV["LIMIT_NOTIFICATION"])
    @next_notifications == 0 ? @notifications : @notifications.next_notifications(@next_notifications)
  end

end