class AllGiftWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(gift_log_id, custom_data = nil)
    @gift_log = GiftLog.find_by(id: gift_log_id)

    raise ArgumentError.new("Gift not found") if @gift_log.nil?

    member_id = 0 # default by system account

    @apn_gift = Apn::AllGift.new(@gift_log)

    @apn_gift.send

    recipient_ids = @apn_gift.recipient_ids

    find_recipient_notify ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient_notify)

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    hash_member_ids_with_reward ||= @apn_gift.hash_member_ids_with_reward

    @custom_properties = {
      type: TYPE[:reward]
    }

    find_recipient_notify.each_with_index do |member, index|
      member.apn_devices.each do |device|
        apn_custom_properties = {
          type: TYPE[:reward],
          reward_id: hash_member_ids_with_reward[member.id],
          redeemable_info: { redeem_id: hash_member_ids_with_reward[member.id] },
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
        notify: hash_list_member_badge[member.id] || 0,
        reward_id: hash_member_ids_with_reward[member.id],
        redeemable_info: { redeem_id: hash_member_ids_with_reward[member.id] },
        worker: WORKER[:all_gift]
      }

      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_gift.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "AllGiftWorker => #{e.message}"
  end

end