class SumVotePollWorker
  include Sidekiq::Worker
  include SymbolHash
  
  def perform(poll_id)
    begin

      poll = Poll.find_by(id: poll_id)

      @poll_serializer_json ||= PollSerializer.new(poll).as_json()

      @apn_sum_vote_poll = Apn::SumVotePoll.new(poll)

      member_id = @apn_sum_vote_poll.get_voted_poll.pluck(:member_id).first

      recipient_ids = @apn_sum_vote_poll.recipient_ids

      find_recipient_notify ||= Member.where(id: recipient_ids)

      @count_notification = CountNotification.new(find_recipient_notify)

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

      if poll.in_group_ids != "0"
        @poll_within_group ||= Group.joins(:poll_groups).where("poll_groups.poll_id = #{poll_id} AND poll_groups.share_poll_of_id = 0").uniq
      end

      @custom_properties = {
        type: TYPE[:poll],
        poll_id: poll.id,
        series: poll.series
      }

      find_recipient_notify.each_with_index do |member, index|
        member.apn_devices.each do |device|
          apn_custom_properties = {
            type: TYPE[:poll],
            poll_id: poll.id,
            series: poll.series,
            notify: hash_list_member_badge[member.id]
          }

          @notf = Apn::Notification.new
          @notf.device_id = device.id
          @notf.badge = hash_list_member_badge[member.id]
          @notf.alert = @apn_sum_vote_poll.custom_message
          @notf.sound = true
          @notf.custom_properties = apn_custom_properties
          @notf.save!
        end
      end

      hash_custom = {
        action: ACTION[:vote],
        poll: @poll_serializer_json
      }

      if @poll_within_group.present?
        group_options = Hash["group" => @poll_within_group.first.as_json()]
        @new_hash_options = @custom_properties.merge!(hash_custom).merge!(group_options)
      else
        @new_hash_options = @custom_properties.merge!(hash_custom)
      end

      find_recipient_notify.each do |member|
        notify_count_json = {
          notify: hash_list_member_badge[member.id]
        }
        NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_sum_vote_poll.custom_message, custom_properties: @new_hash_options.merge!(notify_count_json))
      end

      Apn::App.first.send_notifications

      poll.update_column(:notify_state, 0)
    rescue => e
      poll = Poll.find_by(id: poll_id)
      poll.update_column(:notify_state, 0)
      
      puts "SumVotePollWorker => #{e.message}"
    end
  end

end