class ApnPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, poll)
    @member_id = member_id
    @poll = poll
  end

  def recipient_ids
    apn_friend_ids
  end


  def member_name
    member.sentai_name.split(%r{\s}).first
  end

  def custom_poll_title
    truncate(@poll.title, escape: false, length: 100)
  end
  
  def custom_message
    "#{FEAR} " + member_name + " added a new poll: " + custom_poll_title
  end

  private

  def member
    Member.find(@member_id)
  end

  def apn_friend_ids
    member.cached_get_friend_active.collect{|m| m.id if m.apn_poll_friend }
  end

end

