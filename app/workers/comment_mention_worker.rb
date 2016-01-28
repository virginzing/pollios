class CommentMentionWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(mentioner_id, comment_id, poll_id, mentionable_list)
    mentioner = Member.cached_find(mentioner_id)
    poll = Poll.cached_find(poll_id)

    @poll_serializer_json ||= PollSerializer.new(poll).as_json()

    @apn_comment_mention = Apn::CommentMention.new(mentioner, poll, mentionable_list)

    recipient_ids = mentionable_list

    find_recipient ||= Member.where(id: recipient_ids)

    find_recipient_notify ||= Member.where(id: recipient_ids - [mentioner.id]).uniq

    receive_notification ||= Member.where(id: @apn_comment_mention.receive_notification - [mentioner.id]).uniq

    @count_notification = CountNotification.new(receive_notification)

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    @custom_properties = {
      type: TYPE[:comment],
      comment_id: comment_id,
      poll_id: poll.id,
      series: poll.series
    }

    receive_notification.each_with_index do |member, index|
      member.apn_devices.each do |device|
        apn_custom_properties = {
          type: TYPE[:comment],
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
      voted_detail = { voted: poll.voted?(member) }
      hash_custom = {
        action: ACTION[:mention],
        poll: @poll_serializer_json.merge(voted_detail),
        notify: hash_list_member_badge[member.id],
        worker: WORKER[:comment_mention]
      }

      NotifyLog.create!(sender_id: mentioner.id, recipient_id: member.id, message: @apn_comment_mention.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "CommentMentionWorker => #{e.message}"
  end
end
