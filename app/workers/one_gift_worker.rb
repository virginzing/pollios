class OneGiftWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(receive_id, custom_data = nil)
    begin

      @receive = Member.find_by(id: receive_id)

      raise ArgumentError.new("Member not found") if @receive.nil?

      member_id = 0 # default by system account

      @apn_gift = Apn::Gift.new(@receive, custom_data["message"])

      recipient_ids = @apn_gift.recipient_ids

      find_recipient_notify ||= Member.where(id: recipient_ids).uniq

      @count_notification = CountNotification.new(find_recipient_notify)

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

      @custom_properties = {
        type: TYPE[:reward]
      }

      find_recipient_notify.each_with_index do |member, index|
        member.apn_devices.each do |device|
          apn_custom_properties = {
            type: TYPE[:reward],
            notify: hash_list_member_badge[member.id] || 0
          }

          @notf = Apn::Notification.new
          @notf.device_id = device.id
          @notf.badge = hash_list_member_badge[member.id]
          @notf.alert = @apn_gift.custom_message
          @notf.sound = true
          @notf.custom_properties = apn_custom_properties
          @notf.save!
        end
      end

      find_recipient_notify.each do |member|

        hash_custom = {
          notify: hash_list_member_badge[member.id] || 0
        }

        NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_gift.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "OneGiftWorker => #{e.message}"
    end

  end

end