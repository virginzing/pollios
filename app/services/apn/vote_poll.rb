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
    # @member.sentai_name.split(%r{\s}).first
    @member.sentai_name
  end

  def recipient_ids
    watched_poll
  end
  
  def custom_poll_title
    truncate(@poll.title, escape: false, length: 50)
  end

  # allow 170 byte for custom message
  def custom_message
    if @member.anonymous  ## hide name
      "Someone votes a poll: \"#{custom_poll_title}\""
    else
      "#{member_name} votes a poll: \"#{custom_poll_title}\""
    end
  end

  private

  def watched_poll
    Watched.where(poll_id: @poll.id).pluck(:member_id)
  end
  
end
