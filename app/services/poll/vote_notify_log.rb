class Poll::VoteNotifyLog
  include SymbolHash

  def initialize(sender, poll)
    @poll = poll
    @sender = sender
  end

  def create!
    begin
      raise ArgumentError.new("Poll not found") if @poll.nil?

      @poll_serializer_json ||= PollSerializer.new(@poll).as_json()

      @apn_sum_vote_poll = Apn::SumVotePoll.new(@poll)

      recipient_ids = @apn_sum_vote_poll.recipient_ids

      find_recipient_notify ||= Member.unscoped.where(id: recipient_ids)

      @count_notification = CountNotification.new(find_recipient_notify)

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

      if @poll.in_group_ids != "0"
        @poll_within_group ||= Group.joins(:poll_groups).where("poll_groups.poll_id = #{@poll.id} AND poll_groups.share_poll_of_id = 0").uniq
      end

      @custom_properties = {
        type: TYPE[:poll],
        poll_id: @poll.id,
        series: @poll.series
      }

      hash_custom = {
        anonymous: @apn_sum_vote_poll.anonymous,
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
          notify: hash_list_member_badge[member.id]
        }
        NotifyLog.create!(sender_id: @sender.id, recipient_id: member.id, message: @apn_sum_vote_poll.custom_message, custom_properties: @new_hash_options.merge!(notify_count_json))
      end
    end

  end
  
  
end