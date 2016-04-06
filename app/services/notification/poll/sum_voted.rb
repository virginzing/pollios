class Notification::Poll::SumVoted
  include Notification::Helper
  include SymbolHash

  attr_reader :poll, :member

  def initialize(poll)
    @poll = poll

    create_notification(recipient_list, type, message, data, push: true)

    poll.update!(notify_state: 0)
  end

  def type
    'watch_poll'
  end

  def recipient_list
    member_watched_list - voter_list
  end

  def message
    case voter_list.size
  
    when 1
      message = name_or_anonymous(voter_list.first)
    when 2
      message = name_or_anonymous(voter_list.first) + ' and ' + name_or_anonymous(voter_list.second)
    else
      message = name_or_anonymous(voter_list.first) + ', ' + name_or_anonymous(voter_list.second) + \
                " and #{voter_list.size - 2} other people"
    end

    message + " voted a poll: \"#{poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:poll],
      poll_id: poll.id,
      series: poll.series,
      worker: WORKER[:sum_voted]
    } 
  end

  private

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

  def name_or_anonymous(member)
    member.anonymous ? 'Anonymous' : (member.fullname || 'No name')
  end

  def member_watched_list
    Member.joins('LEFT OUTER JOIN watcheds ON members.id = watcheds.member_id')
      .where("watcheds.poll_id = #{poll.id}")
      .where('watcheds.poll_notify')
  end

end