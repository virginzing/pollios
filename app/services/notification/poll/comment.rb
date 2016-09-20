class Notification::Poll::Comment
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :comment, :poll, :comment_message, :poll_creator

  def initialize(sender, comment)
    @sender = sender
    @comment = comment
    @poll = comment.poll
    @comment_message = comment.message
    @poll_creator = poll.member

    onw_poll? ? create_from_owner_poll : create_from_member
    create_to_mention_list
  end

  def type
    'watch_poll'
  end

  def member_list
    member_watched_list - mention_list
  end

  def data
    @data ||= {
      type: TYPE[:comment],
      comment_id: comment.id,
      poll_id: poll.id,
      poll: PollSerializer.new(poll).as_json,
      series: poll.series,
      worker: WORKER[:comment_poll]
    }
  end

  private

  def onw_poll?
    sender.id == poll_creator.id
  end

  def create_from_owner_poll
    create(member_list, type, message_form_poll_creator, data.merge!(action: ACTION[:also_comment]))
  end

  def create_from_member
    create(member_list - [poll_creator], type, message_form_member_to_a_member, data.merge!(action: ACTION[:also_comment]))
    create([poll_creator], type, message_from_member_to_creator, data.merge!(action: ACTION[:comment]))
  end

  def create_to_mention_list
    return unless mentioning?

    Notification::Poll::Mention.new(sender, comment, mention_list)
  end

  def member_watched_list
    Poll::MemberList.new(poll, viewing_member: sender).watched
  end

  def message_form_poll_creator
    sender.fullname + " also commented in \"#{poll.title}\""
  end

  def message_form_member_to_a_member
    sender.fullname + " also commented in #{poll_creator.fullname}'s poll \"#{poll.title}\""
  end

  def message_from_member_to_creator
    sender.fullname + " commented in \"#{poll.title}\""
  end

  # def adjustment_message
  #   return comment_message unless mentioning?

  #   mention_name = mention_list.each_with_object({}) { |member, hash| hash[member.id] = member.fullname }
  #   comment_message.gsub(/@\[\d+\]/) { |mentioning| mention_name[mentioning.scan(/\d+/).first.to_i] }
  # end

  def mentioning?
    mention_list.empty?
  end

  def mention_list
    @mention_list ||= Member.where(id: mention_ids)
  end

  def mention_ids
    comment_message.gsub(/@\[\d+\]/).map { |m| m.gsub(/\d+/).peek }
  end

end