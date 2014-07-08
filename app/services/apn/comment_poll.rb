class Apn::CommentPoll

  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll, message)
    @member = member
    @poll = poll
    @is_public = false
    @in_group = false
  end

  def member_id
    @member.id
  end

  def member_name
    @member.fullname
  end

  def recipient_ids
    watched_comment
  end
  
  # allow 170 byte for custom message
  def custom_message

    message = "#{member_name} commented your poll: \"#{@poll.title}\""

    truncate_message(message)
  end

  private

  def watched_comment
    Watched.where(poll_id: @poll.id, comment_notify: true).pluck(:member_id)
  end
  
end
