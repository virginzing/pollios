class Notification::Poll::Comment
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :poll, :comment_message, :poll_creator

  def initialize(member, poll, comment_message)
    @member = member
    @poll = poll
    @comment_message = comment_message

    @poll_creator = poll.member

    onw_poll? ? create_from_owner_poll : create_from_member
  end

  def type
    'watch_poll'
  end

  def recipient_list
    member_watched_list
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

  private

  def onw_poll?
    member.id == poll_creator.id
  end

  def create_from_owner_poll
    create(recipient_list, type, message_form_poll_creator, data.merge!(action: ACTION[:also_comment]))
  end

  def create_from_member
    create(recipient_list - [poll_creator], type, message_form_member_to_a_member, data.merge!(action: ACTION[:also_comment]))
    create([poll_creator], type, message_from_member_to_creator, data.merge!(action: ACTION[:comment]))
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
    mention_name = Member.where(id: mention_list).each_with_object({}) { |member, hash| hash[member.id] = member.fullname }
    comment_message.gsub(/@\[\d+\]/) { |mentioning| mention_name[mentioning.scan(/\d+/).first.to_i] }
  end

  def mention_list
    mention_ids = []
    comment_message.gsub(/@\[\d+\]/) { |mentioning| mentioning.gsub(/\d+/) { |number| mention_ids << number } }
    mention_ids.map(&:to_i)
  end

end