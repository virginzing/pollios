class Notification::Poll::Comment
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :poll, :comment_message, :poll_creator

  def initialize(member, poll, comment_message)
    @member = member
    @poll = poll
    @comment_message = comment_message

    @poll_creator = poll.member

    if member.id == poll_creator.id
      create_notification(recipient_list, type, message_form_poll_creator, data.merge!(action: ACTION[:also_comment]))
    else
      create_notification(recipient_list - [poll_creator], type \
        , message_form_member_to_a_member, data.merge!(action: ACTION[:also_comment]))

      create_notification([poll_creator], type, message_from_member_to_creator, data.merge!(action: ACTION[:comment]))
    end
  end

  def type
    'watch_poll'
  end

  def recipient_list
    member_watched_list - [member]
  end

  def data
    @data ||= {
      type: TYPE[:comment],
      comment_id: comment.id,
      poll_id: poll.id,
      series: poll.series,
      worker: WORKER[:comment_poll]
    }
  end

  def member_watched_list
    Member.joins('LEFT OUTER JOIN watcheds ON members.id = watcheds.member_id')
      .where("watcheds.poll_id = #{poll.id}")
      .where('watcheds.comment_notify')
  end

  def message_form_poll_creator
    member.fullname + " also commented on his'poll: \"#{adjustment_message}\""
  end

  def message_form_member_to_a_member
    member.fullname + " also commented on #{poll_creator}'s poll: \"#{adjustment_message}\""
  end

  def message_from_member_to_creator
    member.fullname + " commented your poll: \"#{poll.title}\""
  end

  def adjustment_message
    mentioned_name = Member.where(id: mentioned_list).each_with_object({}) { |member, hash| hash[member.id] = member.fullname }
    comment_message.gsub(/@\[\d+\]/) { |mentioning| mentioned_name[mentioning.scan(/\d+/).first.to_i] }
  end

  def mentioned_list
    mentioned_ids = []
    comment_message.gsub(/@\[\d+\]/) { |mentioning| mentioning.gsub(/\d+/) { |number| mentioned_ids << number } }
    mentioned_ids.map(&:to_i)
  end

end