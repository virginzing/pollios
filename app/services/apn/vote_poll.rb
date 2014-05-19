class Apn::VotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, poll)
    @member_id = member_id
    @poll = poll
  end

  def recipient_id
    @poll.member.id
  end
  
  def custom_poll_title
    truncate(@poll.title, escape: false, length: 100)
  end

  def custom_message
    "Someone votes a poll: \"#{custom_poll_title}\""
  end

  private

  def member
    Member.find(@member_id)
  end
  
end

