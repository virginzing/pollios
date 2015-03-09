class ApnPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @member_id = member.id
    @poll = poll
  end

  def member
    @member
  end

  def recipient_ids
    if member.celebrity? || member.brand?
      apn_friend_ids | follower_ids
    else
      apn_friend_ids
    end
  end

  def member_name
    member.fullname
  end
  
  def custom_message
    message = "#{member_name} added a new poll: \"#{@poll.title}\""
    truncate_message(message)
  end

  private

  def following_ids
    received_notify_of_member_ids(member.get_follower)
  end

  def follower_ids
    received_notify_of_member_ids(member.get_follower)
  end

  def apn_friend_ids
    received_notify_of_member_ids(member.get_friend_active)
  end

end

