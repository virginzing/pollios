class CommentPollWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, poll_id, custom_data = {})
    begin
      member = Member.find(member_id)
      poll = Poll.find(poll_id)
      
      @poll_serializer_json ||= PollSerializer.new(poll).as_json()

      comment_message = custom_data["comment_message"]

      member_id = member.id

      @apn_comment = Apn::CommentPoll.new(member, poll, comment_message)

      recipient_ids = @apn_comment.recipient_ids

      find_recipient ||= Member.where(id: recipient_ids).uniq

      find_recipient_notify ||= Member.where(id: recipient_ids - [member_id]).uniq

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
          @notf.alert = @apn_comment.custom_message(member.id)
          @notf.sound = true
          @notf.custom_properties = apn_custom_properties
          @notf.save!
        end
      end

      find_recipient_notify.each do |member|

        hash_custom = {
          action: @apn_comment.custom_action(member.id),
          poll: @poll_serializer_json,
          comment: comment_message,
          notify: hash_list_member_badge[member.id]
        }

        NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_comment.custom_message(member.id), custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "CommentPollWorker => #{e.message}"
    end
  end

end
