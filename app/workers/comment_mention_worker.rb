class CommentMentionWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(mentioner_id, poll_id, mentionable_list)
    begin
      mentioner = Member.find(mentioner_id)
      poll = Poll.find(poll_id)

      @apn_comment_mention = Apn::CommentMention.new(mentioner, poll)

      recipient_ids = mentionable_list

      find_recipient ||= Member.where(id: recipient_ids)

      find_recipient_notify ||= Member.where(id: recipient_ids - [mentioner.id])

      @custom_properties = { 
        poll_id: poll.id
      }

      find_recipient_notify.each do |member|
        member.apn_devices.each do |device|
          @notf = Apn::Notification.new
          @notf.device_id = device.id
          @notf.badge = 1
          @notf.alert = @apn_comment_mention.custom_message
          @notf.sound = true
          @notf.custom_properties = @custom_properties
          @notf.save!
        end
      end

      find_recipient_notify.each do |member|

        hash_custom = {
          type: TYPE[:comment],
          action: ACTION[:mention],
          poll: PollSerializer.new(poll).as_json()
        }

        NotifyLog.create!(sender_id: mentioner.id, recipient_id: member.id, message: @apn_comment_mention.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "CommentMentionWorker => #{e.message}"
    end
  end
end
