class Apn::FollowMember
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member)
    @member = member
  end

  def custom_message
    message = "#{@member.fullname} is following you."
    truncate_message(message)
  end

end