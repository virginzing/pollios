class Member::NotificationList

  def initialize(member, options = {})
    @member = member
    if options[:page_index]
      @page_index = options[:page_index]
    else
      @page_index = 1
    end
  end

  def notifications_at_current_page
    notifications
  end

  def notifications_count
    notifications.total_entries
  end

  def next_page_index
    notifications.next_page.nil? ? 0 : notifications.next_page
  end

  def reset_new_notification_count
    @member.notification_count = 0
    @member.save!
  end

  private

  def notifications
    @notifications ||= @member.received_notifies.without_deleted.order('created_at DESC').paginate(page: @page_index)
  end

end