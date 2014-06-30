class Apn::VotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def member_id
    @member.id
  end

  def member_name
    @member.fullname
  end

  def recipient_ids
    watched_poll
  end
  
  # allow 170 byte for custom message
  def custom_message
    if @member.anonymous  ## hide name
      message = "Someone votes a poll: \"#{@poll.title}\""
    else
      message = "#{member_name} votes a poll: \"#{@poll.title}\""
    end
    truncate_message(message)
  end

  private

  def watched_poll
    Watched.where(poll_id: @poll.id).pluck(:member_id)
  end
  
end
