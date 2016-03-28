class Notification::Poll::Mention
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :comment, :mention_list, :poll

  def initialize(member, comment, mention_list)
    @member = member
    @comment = comment
    @mention_list = mention_list

    @poll = comment.poll

    create_notification(recipient_list, type, message, data)
  end

  def type
    'watch_poll'
  end

  def recipient_list
    mention_list
  end

  def message
    member.fullname + 'mentioned you in a comment'
  end

  def data
    @data ||= {
      type: TYPE[:comment],
      action: ACTION[:mention],
      comment_id: comment.id,
      poll_id: poll.id,
      series: poll.series,
      worker: WORKER[:mention]
    }
  end

end