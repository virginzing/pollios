class Notification::Poll::SumVoted
  include Notification::Helper
  include SymbolHash

  attr_reader :poll, :sender

  def initialize(poll)
    @poll = poll
    @sender = nil

    create(member_list, type, message, data, push: true)

    poll.update!(notify_state: 0)
  end

  def type
    'watch_poll'
  end

  def member_list
    member_watched_list - recently_voter_list
  end

  def message
    case recently_voter_list.size
  
    when 1
      message = name_or_anonymous(recently_voter_list.first)
    when 2
      message = name_or_anonymous(recently_voter_list.first) + ' and ' + name_or_anonymous(recently_voter_list.second)
    else
      message = name_or_anonymous(recently_voter_list.first) + ', ' + name_or_anonymous(recently_voter_list.second) + \
                " and #{recently_voter_list.size - 2} other people"
    end

    message + " voted on \"#{poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:poll],
      poll_id: poll.id,
      poll: PollSerializer.new(poll).as_json,
      series: poll.series,
      worker: WORKER[:sum_voted]
    } 
  end

  private

  def poll_member_listing
    Poll::MemberList.new(poll)
  end

  def member_watched_list
    poll_member_listing.watched
  end

  def recently_voter_list
    poll_member_listing.recently_voter
  end

  def name_or_anonymous(member)
    member.anonymous ? 'Anonymous' : (member.fullname || 'No name')
  end

end