class Notification::Poll::Vote
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll, :anonymous

  def initialize(member, poll, anonymous = false)
    @sender = member
    @poll = poll
    @anonymous = anonymous

    create(recipient_list, type, message, data, log: true)
  end

  def type
    'watch_poll'
  end

  def recipient_list
    member_watched_list
  end

  def message
    name_or_anonymous(sender) + " voted on \"#{poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:poll],
      poll_id: poll.id,
      series: poll.series,
      anonymous: anonymous,
      action: ACTION[:vote],
      poll: PollSerializer.new(poll).as_json
    } 
  end

  private

  def name_or_anonymous(member)
    anonymous ? 'Anonymous' : (member.fullname || 'No name')
  end

  def member_watched_list
    Poll::MemberList.new(poll, viewing_member: sender).watched
  end
end