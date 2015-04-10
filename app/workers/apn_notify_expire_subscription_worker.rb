class ApnNotifyExpireSubscriptionWorker

  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true


  def perform(sender_id, list_member, custom_data = {})
    begin
      find_recipient ||= Member.where(id: list_member).uniq

      @apn_notify_expire_subscription = Apn::NotifyExpireSubscription.new

      @count_notification = CountNotification.new(find_recipient)

      device_ids ||= @count_notification.device_ids

      member_ids ||= @count_notification.member_ids

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

      @custom_properties = {
        type: TYPE[:subscription]
      }

      device_ids.each_with_index do |device_id, index|
        apn_custom_properties = {
          type: TYPE[:subscription],
          notify: hash_list_member_badge[member_ids[index]]
        }

        @notf = Apn::Notification.new
        @notf.device_id = device_id
        @notf.badge = hash_list_member_badge[member_ids[index]]
        @notf.alert = @apn_notify_expire_subscription.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end

      find_recipient.each do |member|
        hash_custom = {
          notify: hash_list_member_badge[member.id]
        }

        NotifyLog.create!(sender_id: sender_id, recipient_id: member.id, message: @apn_notify_expire_subscription.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "ApnNotifyExpireSubscriptionWorker => #{e.message}"
    end
  end
  
end
