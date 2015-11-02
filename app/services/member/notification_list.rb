class Member::NotificationList

  module ListType
    BY_PAGE = 0
    BY_ID = 1
  end

  def initialize(member, options = {})
    @member = member

    if options[:index]
      @index = options[:index]
    else
      @index = 1
    end

    if options[:clear_new_count]
      reset_new_notification_count
    end

    @list_type = ListType::BY_PAGE
  end

  def notifications_at_current_page
    if @list_type == ListType::BY_PAGE
      notifications_by_page
    else
      notifications_by_page
    end
  end

  def next_index
    if @list_type == ListType::BY_PAGE
      next_page_index
    else
      next_page_index
    end
  end

  def reset_new_notification_count
    @member.notification_count = 0
    @member.save!
  end

  private

  def next_page_index
    notifications_by_page.next_page.nil? ? 0 : notifications_by_page.next_page
  end

  def notifications_by_page
    @notifications_by_page ||= @member.received_notifies.without_deleted.order('created_at DESC').paginate(page: @index)
  end

end