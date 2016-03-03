class Member::NotificationAction

  attr_reader :member, :notification

  def initialize(member, notification)
    @member = member
    @notification = notification

    fail ExceptionHandler::UnprocessableEntity, "This notification doesn't exist in your notification" \
      unless notification.recipient_id == member.id
  end

  def hide
    notification.destroy

    nil
  end

end