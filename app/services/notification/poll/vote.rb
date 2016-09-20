class Notification::Poll::Vote
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll, :anonymous

  def initialize(sender, poll, anonymous = false)
    @sender = sender
    @poll = poll
    @anonymous = anonymous

    create(member_list, type, message, data, log: true)
  end

  def type
    'watch_poll'
  end

  def member_list
    member_watched_list
  end

  def message
    name_or_anonymous(sender) + " voted on \"#{poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:poll],
      poll_id: poll.id,
      poll: PollSerializer.new(poll).as_json,
      series: poll.series,
      anonymous: anonymous,
      action: ACTION[:vote]
    } 
  end

  private

  def name_or_anonymous(sender)
    anonymous ? 'Anonymous' : (sender.fullname || 'No name')
  end

  def member_watched_list
    Poll::MemberList.new(poll, viewing_member: sender).watched
  end
end