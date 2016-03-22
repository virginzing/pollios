class Notification::Poll::VotePoll
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :poll, :anonymous 

  def initialize(member, poll, options = { anonymous: false })
    @member = member
    @poll = poll
    @anonymous = options[:anonymous]
  end

  def type
    'watch_poll'
  end

  def recipient_list
    member_watched_list - voter_list - [member]
  end

  def message
    voter_names + " voted a poll: \"#{poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:poll],
      poll_id: poll.id,
      series: poll.series,
      worker: WORKER[:vote_poll]
    } 
  end

  # private

  def voter_list
    Member.joins('LEFT OUTER JOIN history_votes ON members.id = history_votes.member_id')
      .where("history_votes.poll_id = #{poll.id}")
      .where('history_votes.created_at >= ?', last_push_notification_at)
      .select('members.*, history_votes.created_at AS voted_at, (NOT history_votes.show_result) AS anonymous')
      .order('voted_at DESC')
  end

  def last_push_notification_at
    poll.notify_state_at || 1.minutes.ago
  end

  def voter_names
    return voter_list.first.fullname if voter_list.size == 1
    return voter_list.map(&:fullname).join(' and ') if voter_list.size == 2
    voter_list.first.fullname + ', ' + voter_list.second.fullname + " and #{voter_list.size - 2} other people"
  end

  def member_watched_list
    Member.joins('LEFT OUTER JOIN watcheds ON members.id = watcheds.member_id')
      .where("watcheds.poll_id = #{poll.id}")
      .where('watcheds.poll_notify')
  end

end