class Poll::CommentNotifyLog
  include SymbolHash

  def initialize(sender, poll, custom_data)
    @sender = sender
    @poll = poll
    @custom_data = custom_data
  end

  def poll
    @poll
  end

  def comment_message
    @custom_data["comment_message"]
  end

  def member_id
    @sender.id
  end

  def create!    
    raise ArgumentError.new(ExceptionHandler::Message::Poll::NOT_FOUND) if poll.nil?
    
    @poll_serializer_json ||= PollSerializer.new(poll).as_json()

    @apn_comment = Apn::CommentPoll.new(@sender, poll, comment_message)

    recipient_ids = @apn_comment.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids).uniq

    find_recipient_notify ||= Member.where(id: recipient_ids - [member_id]).uniq

    @count_notification = CountNotification.new(find_recipient_notify)

    get_hash_list_member_badge ||= @count_notification.get_hash_list_member_badge_count

    @custom_properties = {
      type: TYPE[:comment],
      poll_id: poll.id,
      series: poll.series
    }

    find_recipient_notify.each do |member|
      hash_custom = {
        action: @apn_comment.custom_action(member.id),
        poll: @poll_serializer_json,
        comment: comment_message,
        notify: get_hash_list_member_badge[member.id]
      }
      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_comment.custom_message(member.id), custom_properties: @custom_properties.merge!(hash_custom))
    end

  end  
  
  
end