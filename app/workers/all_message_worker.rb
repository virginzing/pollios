class AllMessageWorker
    include Sidekiq::Worker
    include SymbolHash

    sidekiq_options unique: true

    def perform(message_log_id, custom_data = nil)
        @message_log = MessageLog.find_by(id: message_log_id)

        raise ArgumentError.new("Message not found") if @message_log.nil?

        member_id = 0 # default system account

        @apn_message = Apn::AllMessage.new(@message_log)

        recipient_ids = @apn_message.recipient_ids
        find_recipient_notify ||= Member.where(id: recipient_ids).uniq

        @count_notification = CountNotification.new(find_recipient_notify)

        hash_list_member_badge ||= @count_notification.hash_list_member_badge

        @custom_properties = {
            type: TYPE[:system_message]
        }

        find_recipient_notify.each_with_index do |recipient, index|

            device = recipient.apn_devices.last

            # recipient.apn_devices.each do |device|
                apn_custom_properties = {
                    type: [:system_message],
                    notify: hash_list_member_badge[recipient.id] || 0
                }

                @notif = Apn::Notification.new
                @notif.device_id = device.id
                @notif.badge = hash_list_member_badge[recipient.id]
                @notif.alert = @apn_message.custom_message
                @notif.sound = true
                @notif.custom_properties = apn_custom_properties
                @notif.save!
            # end
        end

        find_recipient_notify.each do |recipient|
            hash_custom = {
                notify: hash_list_member_badge[recipient.id] || 0,
                worker: WORKER[:all_message]
            }

            NotifyLog.create!(sender_id: member_id, recipient_id: recipient.id, message: @apn_message.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
        end

        Apn::App.first.send_notifications
    rescue => e
        puts "AllMessageWorker => #{e.message}"
    end
end