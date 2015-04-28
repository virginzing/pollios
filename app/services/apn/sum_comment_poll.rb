class Apn::SumCommentPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(poll)
    @poll = poll
  end

  def recipient_ids
    watched_comment
  end

  def last_comment_notify_at
    @poll.comment_notify_state_at.present? ? @poll.comment_notify_state_at : 1.minutes.ago
  end

  def get_comment_poll
    @get_comment_poll ||= comment_poll
  end

  def commenter_fullname
    @commenter_fullname ||= get_comment_poll.collect{|e| e.member_fullname }
  end

  def comment_count
    @comment_count ||= get_comment_poll.to_a.size
  end

  def custom_message
    count = comment_count
    fullname = commenter_fullname

    if count == 1
      message = "#{fullname[0]} commented poll: \"#{@poll.title}\""
    elsif count == 2
      message = "#{fullname[0..1].join(" and ")} commented poll: \"#{@poll.title}\""
    elsif count > 2
      message = "#{fullname[0..1].join(", ")} and #{(count-2)} other people commented poll: \"#{@poll.title}\""
    else
      message = ""
    end

    truncate_message(message)
  end


  private

  def watched_comment
    Watched.joins(:member).where("poll_id = ? AND comment_notify = 't' AND members.receive_notify = 't'", @poll.id).pluck(:member_id).uniq
  end

  def comment_poll
    Comment.joins(:member)
                .select("member_id, members.fullname as member_fullname")
                .where("comments.poll_id = ? AND comments.created_at >= ?", @poll.id, last_comment_notify_at)
  end
  
end