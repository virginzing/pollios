class Apn::SumVotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(poll)
    @poll = poll
  end

  def recipient_ids
    watched_poll
  end

  def last_notify_at
    @poll.notify_state_at.present? ? (@poll.notify_state_at - 0.5.seconds) : 1.minutes.ago
  end

  def get_voted_poll
    get_voted_poll ||= voted_poll
  end

  def custom_message
    count = get_voted_poll.pluck(:member_id).count

    fullname = get_voted_poll.pluck(:fullname)

    if count == 1
      message = "#{fullname[0]} voted a poll: \"#{@poll.title}\""
    elsif count == 2
      message = "#{fullname[0..1].join(" and ")} voted a poll: \"#{@poll.title}\""
    elsif count > 2
      message = "#{fullname[0..1].join(", ")} and #{(count-2)} other people voted a poll: \"#{@poll.title}\""
    else
      message = ""
    end

    truncate_message(message)
  end

  private

  def watched_poll
    Watched.where(poll_id: @poll.id, poll_notify: true).pluck(:member_id)
  end

  def voted_poll
    HistoryVote.joins(:member).select("member_id, members.fullname as fullname").where("(poll_id = ? AND poll_series_id = 0 AND history_votes.created_at >= ?)", @poll.id, last_notify_at)
  end
  
end