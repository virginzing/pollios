class Apn::FollowMember
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, friend)
    @member = member
    @friend = friend
  end

  def count_notification
    if @friend.apn_devices.present?
      @friend.increment!(:notification_count)
      return @friend.notification_count
    end
  end


  def custom_message
    message = "#{@member.fullname} is following you"
    truncate_message(message)
  end

end