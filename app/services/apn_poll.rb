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
      apn_friend_ids | following_ids
    else
      apn_friend_ids
    end
  end

  def member_name
    member.sentai_name
  end
  
  def custom_message
    message = member_name + " added a new poll: " + @poll.title
    truncate_message(message)
  end

  private

  def following_ids
    member.cached_get_follower.collect{|m| m.id if m.apn_poll_friend }
  end

  def apn_friend_ids
    member.cached_get_friend_active.collect{|m| m.id if m.apn_poll_friend }
  end

end

