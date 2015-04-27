class Apn::CommentPoll
  include SymbolHash
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
    summary_member_receive_notification
  end
  
  # allow 130 byte for custom message
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

  def custom_action(receiver_id)
    if receiver_id == poll_creator_id
      ACTION[:comment]
    else
      ACTION[:also_comment]
    end
  end

  private

  def watched_comment
    Watched.joins(:member).where("poll_id = ? AND comment_notify = 't' AND members.receive_notify = 't'", @poll.id).pluck(:member_id).uniq
  end

  def list_mentioned
    []
  end


  def summary_member_receive_notification
    watched_comment - list_mentioned
  end
  
end
