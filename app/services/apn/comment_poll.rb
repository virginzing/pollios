class Apn::CommentPoll

  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll, message)
    @message = message
    @member = member
    @poll = poll
    @is_public = false
    @in_group = false
  end

  def member_id
    @member.id
  end

  def poll_creator_id
    @poll.member.id
  end

  def member_name
    @member.fullname
  end

  def recipient_ids
    watched_comment
  end
  
  # allow 170 byte for custom message
  def custom_message(receiver_id)
    if receiver_id == poll_creator_id
      message = "#{member_name} commented your poll: \"#{@poll.title}\""
    elsif member_id == poll_creator_id
      message = "#{member_name} also commented on his'poll: \"#{@message}\""
    else
      message = "#{member_name} also commented on #{@poll.member.fullname}'s poll: \"#{@message}\""
    end
    truncate_message(message)
  end

  private

  def watched_comment
    Watched.where(poll_id: @poll.id, comment_notify: true).pluck(:member_id)
  end
  
end
