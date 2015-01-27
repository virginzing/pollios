class Apn::SumVotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  PUBLIC = 'PUBLIC'
  GROUP = 'GROUP'
  FRIEND = 'FRIEND'
  SOMEONE = 'Someone'

  def initialize(poll)
    @poll = poll
  end

  def recipient_ids
    watched_poll
  end

  def last_notify_at
    @poll.notify_state_at.present? ? @poll.notify_state_at : 1.minutes.ago
  end

  def get_voted_poll
    @get_voted_poll ||= voted_poll
  end

  def get_load_privacy
    @get_load_privacy ||= check_privacy_vote
  end

  def anonymous
    if get_load_privacy.first == SOMEONE
      true
    else
      false
    end
  end

  def custom_message
    count = get_voted_poll.map(&:member_id).count

    @list_fullname = get_voted_poll.map(&:new_fullname)

    new_fullname = get_load_privacy

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

  private

  def check_privacy_vote
    if @poll.public
      load_privacy_vote(PUBLIC)
    else
      if @poll.in_group
        load_privacy_vote(GROUP)
      else
        load_privacy_vote(FRIEND)
      end
    end
    convert_list_fullname
  end

  def load_privacy_vote(type)
    case type
      when PUBLIC
        @load_privacy_vote = get_voted_poll.map(&:privacy_vote_public)
      when GROUP
        @load_privacy_vote = get_voted_poll.map(&:privacy_vote_group)
      when
        @load_privacy_vote = get_voted_poll.map(&:privacy_vote_friend_following)
    end
  end

  def convert_list_fullname
    new_fullname = []
    @list_fullname.each_with_index do |fullname, index|
      if @load_privacy_vote[index]
        new_fullname << SOMEONE
      else
        new_fullname << fullname
      end
    end
    new_fullname
  end

  def watched_poll
    # Watched.joins(:member).where(poll_id: @poll.id, poll_notify: true).pluck(:member_id)
    Watched.joins(:member).where("poll_id = ? AND poll_notify = 't' AND members.receive_notify = 't'", @poll.id).pluck(:member_id).uniq
  end
  
  def voted_poll
    HistoryVote.joins(:member)
                .select("member_id, members.fullname as new_fullname, members.anonymous_public as privacy_vote_public, members.anonymous_friend_following as privacy_vote_friend_following, members.anonymous_group as privacy_vote_group")
                .where("(poll_id = ? AND poll_series_id = 0 AND history_votes.created_at >= ?)", @poll.id, last_notify_at)
  end
  
end