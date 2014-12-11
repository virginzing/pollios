class CommentMentionWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(mentioner_id, poll_id, mentionable_list)
    begin
      mentioner = Member.find(mentioner_id)
      poll ||= Poll.find(poll_id)
      @poll_serializer_json ||= PollSerializer.new(poll).as_json()

      @apn_comment_mention = Apn::CommentMention.new(mentioner, poll)

      recipient_ids = mentionable_list

      find_recipient ||= Member.where(id: recipient_ids)

      find_recipient_notify ||= Member.where(id: recipient_ids - [mentioner.id])

      @count_notification = CountNotification.new(find_recipient_notify)

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

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
          @notf.alert = @apn_comment_mention.custom_message
          @notf.sound = true
          @notf.custom_properties = apn_custom_properties
          @notf.save!
        end
      end

      find_recipient_notify.each do |member|
        hash_custom = {
          action: ACTION[:mention],
          poll: @poll_serializer_json,
          notify: hash_list_member_badge[member.id]
        }

        NotifyLog.create!(sender_id: mentioner.id, recipient_id: member.id, message: @apn_comment_mention.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "CommentMentionWorker => #{e.message}"
    end
  end
end
