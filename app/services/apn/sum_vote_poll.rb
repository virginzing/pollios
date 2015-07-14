class Apn::SumVotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  PUBLIC = 'PUBLIC'
  GROUP = 'GROUP'
  FRIEND = 'FRIEND'
  SOMEONE = 'Anonymous'

  def initialize(poll, except_member_ids_list = [])
    @poll = poll
    @except_member_ids_list = except_member_ids_list
  end

  def recipient_ids
    member_receive_notification
  end

  def except_member_list
    @except_member_ids_list || []
  end

  def last_notify_at
    @poll.notify_state_at.present? ? @poll.notify_state_at : 1.minutes.ago
  end

  def get_voted_poll
    @get_voted_poll ||= voted_poll
  end

  def convert_list_fullname
    @convert_list_fullname ||= check_privacy_with_fullname
  end

  # def get_load_privacy
  #   @get_load_privacy ||= check_privacy_vote
  # end

  def anonymous
    convert_list_fullname.first == SOMEONE ? true : false
  end

  def custom_message
    count = get_voted_poll.map(&:member_id).size

    new_fullname ||= convert_list_fullname

    if count == 1
      message = "#{new_fullname[0]} voted a poll: \"#{@poll.title}\""
    elsif count == 2
      message = "#{new_fullname[0..1].join(" and ")} voted a poll: \"#{@poll.title}\""
    elsif count > 2
      message = "#{new_fullname[0..1].join(", ")} and #{(count-2)} other people voted a poll: \"#{@poll.title}\""
    else
      message = ""
    end

    truncate_message(message)
  end

  def vote_notify_custom_message(sender, show_result)
    sender_name = show_result ? sender.get_name : "Anonymous"
    message = "#{sender_name} voted a poll: \"#{@poll.title}\""

    truncate_message(message)
  end

  private

  def check_privacy_with_fullname
    @list_fullname = []

    get_voted_poll.each do |m|
      if m.member_fullname.present?
        @list_fullname << m.member_fullname
      else
        @list_fullname << "No name"
      end
    end

    @load_privacy_vote = get_voted_poll.map(&:show_voter)

    # puts "@list_fullname => #{@list_fullname}"

    # puts "@load_privacy_vote => #{@load_privacy_vote}"

    new_fullname = []

    @list_fullname.each_with_index do |fullname, index|
      if @load_privacy_vote[index]
        new_fullname << fullname
      else
        new_fullname << SOMEONE
      end
    end
    new_fullname
  end


  def history_vote_in_1_minute
    HistoryVote.unscoped.where(created_at: @poll.notify_state_at..(@poll.notify_state_at + 1.minute)).pluck(:member_id).uniq
  end

  def watched_poll
    watched_poll = Watched.joins(:member).where("poll_id = ? AND poll_notify = 't' AND members.receive_notify = 't'", @poll.id).pluck(:member_id).uniq
  end

  def member_receive_notification
    list_members = Member.where(id: (watched_poll - history_vote_in_1_minute - except_member_list))
    getting_notification(list_members, "watch_poll")
  end

  def voted_poll
    HistoryVote.joins(:member)
                .select("member_id, members.fullname as member_fullname, history_votes.show_result as show_voter")
                .where("poll_id = ? AND poll_series_id = 0 AND history_votes.created_at >= ?", @poll.id, last_notify_at)
  end
end
