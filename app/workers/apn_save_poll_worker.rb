class ApnSavePollWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true
  
  def perform(custom_data = {})
    member_id = 0 # default by system account

    @apn_save_poll = Apn::SavePoll.new

    recipient_ids = @apn_save_poll.recipient_ids

    find_recipient_notify ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient_notify)

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    @custom_properties = {
      type: TYPE[:save_poll_later]
    }

    find_recipient_notify.each_with_index do |member, index|
      member.apn_devices.each do |device|
        apn_custom_properties = {
          type: TYPE[:save_poll_later],
          notify: hash_list_member_badge[member.id] || 0
        }

        @notf = Apn::Notification.new
        @notf.device_id = device.id
        @notf.badge = hash_list_member_badge[member.id]
        @notf.alert = @apn_save_poll.custom_message(member.id)
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end
    end

    find_recipient_notify.each do |member|
      hash_custom = {
        notify: hash_list_member_badge[member.id] || 0
      }
      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_save_poll.custom_message(member.id), custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "ApnSavePollWorker => #{e.message}"
  end

end
