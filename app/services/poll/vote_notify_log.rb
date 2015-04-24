class Poll::VoteNotifyLog
  include SymbolHash

  def initialize(sender, poll, show_result)
    @poll = poll
    @sender = sender
    @show_result = show_result
  end

  def anonymous
    !@show_result
  end

  def create!
    begin
      raise ArgumentError.new(ExceptionHandler::Message::Poll::NOT_FOUND) if @poll.nil?

      @poll_serializer_json ||= PollSerializer.new(@poll).as_json()

      @apn_sum_vote_poll = Apn::SumVotePoll.new(@poll, [@sender.id])

      recipient_ids = @apn_sum_vote_poll.recipient_ids

      find_recipient_notify ||= Member.unscoped.where(id: recipient_ids)

      @count_notification = CountNotification.new(find_recipient_notify)

      get_hash_list_member_badge ||= @count_notification.get_hash_list_member_badge_count

      if @poll.in_group_ids != "0"
        @poll_within_group ||= Group.joins(:poll_groups).where("poll_groups.poll_id = #{@poll.id} AND poll_groups.share_poll_of_id = 0").uniq
      end

      @custom_properties = {
        type: TYPE[:poll],
        poll_id: @poll.id,
        series: @poll.series
      }

      hash_custom = {
        anonymous: anonymous,
        action: ACTION[:vote],
        poll: @poll_serializer_json
      }

      if @poll_within_group.present?
        group_options = Hash["group" => GroupNotifySerializer.new(@poll_within_group.first).as_json()]
        @new_hash_options = @custom_properties.merge!(hash_custom).merge!(group_options)
      else
        @new_hash_options = @custom_properties.merge!(hash_custom)
      end

      find_recipient_notify.each do |member|
        notify_count_json = {
          notify: (get_hash_list_member_badge[member.id] + 1)
        }
        NotifyLog.create!(sender_id: @sender.id, recipient_id: member.id, message: @apn_sum_vote_poll.vote_notify_custom_message(@sender, @show_result), custom_properties: @new_hash_options.merge!(notify_count_json))
      end
    end

  end
  
  
end