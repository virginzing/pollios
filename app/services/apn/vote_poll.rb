class Apn::VotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, poll)
    @member_id = member_id
    @poll = poll
  end

  def recipient_ids
    # @poll.member.id
    watched_poll
  end
  
  def custom_poll_title
    truncate(@poll.title, escape: false, length: 100)
  end

  # allow 170 byte for custom message
  def custom_message
    "Someone votes a poll: \"#{custom_poll_title}\""
  end

  private

  def watched_poll
    Watched.where(poll_id: @poll.id).pluck(:member_id)
  end

  def member
    Member.find(@member_id)
  end
  
end
