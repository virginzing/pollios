class Member::NotificationAction

  attr_reader :member, :notification_list

  def initialize(member, notification_list)
    @member = member
    @notification_list = notification_list

    fail ExceptionHandler::UnprocessableEntity, "This notification doesn't exist in your notifications" \
      unless notification_list.map(&:recipient_id).uniq == [member.id]
  end

  def hide
    notification_list.update_all(deleted_at: Time.now)

    nil
  end

end