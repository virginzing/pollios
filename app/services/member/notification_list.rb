class Member::NotificationList

  attr_reader :member, :index

  def initialize(member, options = {})
    @member = member
    @index = options[:index] || 1

    reset_new_notification_count if options[:clear_new_count]
  end

  def all
    all_notification.to_a
  end

  def notifications_at_current_page
    notifications_by_page
  end

  def next_index
    next_page_index
  end

  def reset_new_notification_count
    member.notification_count = 0
    member.save!
  end

  private

  def next_page_index
    notifications_by_page.next_page || 0
  end

  def notifications_by_page
    @notifications_by_page ||= all_notification.paginate(page: index)
  end

  def all_notification
    @all_notification ||= member.received_notifies.without_deleted.order('created_at DESC')
  end

end
