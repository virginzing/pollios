class AddFriend
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, friend, options = {})
    @member = member
    @friend = friend
    @options = options
  end

  def recipient_id
    @friend.id
  end

  def receive_notification
    list_members = Member.where(id: recipient_id)
    getting_notification(list_members, "request")
  end

  def check_apn_device?
    friend_deivce ||= @friend.apn_devices.present?
  end

  def count_notification
    @friend.increment!(:notification_count)
    return @friend.notification_count
  end

  def count_request
    @friend.increment!(:request_count)
    return @friend.request_count
  end

  def custom_message
    if @options["accept_friend"]
      message = @member.get_name + " had accepted your friend request"
    else
      message = @member.get_name + " request friend with you"
    end
    truncate_message(message)
  end

end
