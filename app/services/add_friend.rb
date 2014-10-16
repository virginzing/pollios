class AddFriend
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, friend, options = {})
    @member = member
    @friend = friend
    @options = options
  end

  def recipient_id
    if @friend
      @friend.apn_add_friend ? @friend.id : nil
    end
  end

  def check_apn_device?
    friend_deivce ||= @friend.apn_devices.present?
  end

  def count_notification
    @friend.update_columns(notification_count: @friend.notification_count + 1)
    return @friend.notification_count
  end

  def count_request
    @friend.update_columns(request_count: @friend.request_count + 1)
    return @friend.request_count
  end

  def member_name
    # member.fullname.split(%r{\s}).first
    @member.fullname
  end

  def friend_name
    @friend.fullname
  end

  def custom_message
    if @options["accept_friend"]
      message = member_name + " is now friends with you"
    else
      message = member_name + " request friend with you" 
    end
    truncate_message(message)
  end
  
end