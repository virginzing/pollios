class ApnPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, poll)
    @member_id = member_id
    @poll = poll
  end

  def recipient_ids
    if member.celebrity? || member.brand?
      apn_friend_ids | following_ids
    else
      apn_friend_ids
    end
  end


  def member_name
    member.sentai_name.split(%r{\s}).first
  end

  def custom_poll_title
    truncate(@poll.title, escape: false, length: 50)
  end
  
  def custom_message
    member_name + " added a new poll: " + custom_poll_title
  end

  private

  def member
    Member.find(@member_id)
  end

  def following_ids
    member.cached_get_follower.collect{|m| m.id if m.apn_poll_friend }
  end

  def apn_friend_ids
    member.cached_get_friend_active.collect{|m| m.id if m.apn_poll_friend }
  end

end

