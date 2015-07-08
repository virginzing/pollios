class SumVotePollWorker
  include Sidekiq::Worker
  include SymbolHash

  # sidekiq_options unique: true, :retry => 1
  
  def perform(poll_id, show_result = true)
    begin
      @list_apn_notification = []

      poll = Poll.find_by(id: poll_id)

      raise ArgumentError.new(ExceptionHandler::Message::Poll::NOT_FOUND) if poll.nil?

      @poll_serializer_json ||= PollSerializer.new(poll).as_json()

      @apn_sum_vote_poll = Apn::SumVotePoll.new(poll)

      member_id = @apn_sum_vote_poll.get_voted_poll.map(&:member_id).first

      recipient_ids = @apn_sum_vote_poll.recipient_ids

      find_recipient_notify ||= Member.unscoped.where(id: recipient_ids)

      @count_notification = CountNotification.new(find_recipient_notify)

      get_hash_list_member_badge ||= @count_notification.get_hash_list_member_badge_count

      if poll.in_group_ids != "0"
        @poll_within_group ||= Group.joins(:poll_groups).where("poll_groups.poll_id = #{poll_id} AND poll_groups.share_poll_of_id = 0").uniq
      end

      @custom_properties = {
        type: TYPE[:poll],
        poll_id: poll.id,
        series: poll.series,
        worker: WORKER[:sum_vote_poll]
      }

      find_recipient_notify.each_with_index do |member, index|
        member.apn_devices.each do |device|
          apn_custom_properties = {
            type: TYPE[:poll],
            poll_id: poll.id,
            series: poll.series,
            notify: (get_hash_list_member_badge[member.id] + 1)
          }

          @notf = Apn::Notification.new
          @notf.device_id = device.id
          @notf.badge = (get_hash_list_member_badge[member.id] + 1)
          @notf.alert = @apn_sum_vote_poll.custom_message
          @notf.sound = true
          @notf.custom_properties = apn_custom_properties
          @notf.save!

          @list_apn_notification << @notf
        end
        member.update_columns(notification_count: (get_hash_list_member_badge[member.id] + 1))
      end

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

      Apn::App.first.send_notifications

      poll.update!(notify_state: 0)
      # p "Notify vote sucessfully"
    rescue => e
      poll = Poll.find_by(id: poll_id)
      poll.update!(notify_state: 0) if poll.present?
      # puts "SumVotePollWorker => #{e.message}"
      @list_apn_notification.collect{|apn_notification| apn_notification.destroy }
    end
  end
end